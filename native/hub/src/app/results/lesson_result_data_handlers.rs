pub mod lesson_result_data_handlers {
    use http::StatusCode;
    use crate::bridge::send_rust_signal;
    use crate::app::entry::menu::menu_data_object::{Root, MenuDataObject};
    use crate::app::settings::settings_data_object::SettingsDataObject;
    use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
    // use crate::messages::entry::menu::menu::CreateRequest;
    // use crate::messages::entry::upload::uploaded_content;
    use prost::Message;
    use tokio_with_wasm::tokio;
    
    use std::fs::{OpenOptions, create_dir_all, File};
    use std::io::{Write, Read};
    use std::thread::sleep;
    
    use crate::app::utils::{scrapers, lesson_generator};
    use crate::app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;
    use crate::app::lesson::lesson_specifications_data_object::LessonSpecificationsDataObject;
    use crate::app::results::lesson_result_data_object::{LessonResultDataObject, Sources};
    
    use crate::app::global_objects::lessons_data_object::{Lesson, LessonsDataObject};
    
    impl LessonsDataObject{
        fn create_lesson(&mut self, new_lesson: Lesson) {
            // Check for duplicate target_path before adding
            if !self.lessons.iter().any(|lesson| lesson.target_path == new_lesson.target_path) {
                self.lessons.push(new_lesson);
                crate::debug_print!("Lesson added successfully!");
            } else {
                crate::debug_print!("Error: Duplicate target_path found. Lesson not added.");
            }
        }
    
        fn remove_lesson(&mut self, target_path: &str) {
            if let Some(index) = self.lessons.iter().position(|lesson| lesson.target_path == target_path) {
                self.lessons.remove(index);
                crate::debug_print!("Lesson with target_path '{}' removed successfully!", target_path);
            } else {
                crate::debug_print!("Error: Lesson with target_path '{}' not found.", target_path);
            }
        }
    }
    
    // Handler functions
    pub async fn handle_lesson_generation(rust_request: RustRequest,
        upload_data_object: &mut tokio::sync::MutexGuard<'_, UploadSourcesDataObject>,
        lesson_specifications_data_object: &mut tokio::sync::MutexGuard<'_, LessonSpecificationsDataObject>,
        settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
        menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> RustResponse {
        use crate::messages::results::view_lesson_result::load_lesson::{CreateRequest, CreateResponse, ReadRequest, ReadResponse};
        
        // TODO: MAKE THIS GLOBAL
        let release = true; // DEBUG MODE
    
        match rust_request.operation {
            RustOperation::Create => {
                let message_bytes = rust_request.message.unwrap();
                let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

                let lesson_content = request_message.lesson_content;
                
                let sanitized_title = lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone().replace(" ", "_");
                
                // File path of config.json
                let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
                
                // File path of target/output.md
                let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);

                match write_lesson_to_target_path(&lesson_content, &target_folder_path) {
                    Ok(_) => {
                        crate::debug_print!("Wrote to lesson target file path at {}", target_folder_path);
                    }

                    Err(error) => {
                        crate::debug_print!("Failed to write lesson to target: {}", error);
                        let response_message = CreateResponse{
                            status_code: StatusCode::BAD_REQUEST.as_u16() as u32,
                        };

                        return RustResponse {
                            successful: false,
                            message: Some(response_message.encode_to_vec()),
                            blob: None,
                        }
                    }
                }
                
                let response_message = CreateResponse{
                    status_code: StatusCode::OK.as_u16() as u32,
                };

                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
            RustOperation::Read => {
                // Handles the lesson generation
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;
    
                // let response_message;
    
                let mut string_payload: String = String::new();
                
                let mut lessons_json = LessonsDataObject { lessons: Vec::new() };
                let mut sources = Sources::default();
                
                string_payload.push_str("Lesson Specifications \n");
    
                for lesson_specification in &lesson_specifications_data_object.lesson_specifications {
                    string_payload.push_str(&lesson_specification);
                    string_payload.push_str("\n"); 
                    crate::debug_print!("Lesson Spec: {}", &lesson_specification);
                }
    
                string_payload.push_str("------------------------------- \n");
    
                for file_path in &upload_data_object.file_paths {
                    if file_path.to_lowercase().ends_with(".pdf") {
                        // TODO: Implement other scrapers for other text file formats
                        match scrapers::scrape_pdf(file_path.to_string()) {
                            Ok(pdf_content) => {
                                string_payload.push_str(&pdf_content);
                                string_payload.push_str("\n"); 
                                sources.source_files.push(file_path.clone())
                            }
                            Err(err) => {
								crate::debug_print!("[Scraper] >>> {} ", err);
                            }
                        }
                    }
                }
    
                for url in &upload_data_object.urls {
                    match scrapers::scrape_url(url.to_string()) {
                        Ok(web_content) => {
                            string_payload.push_str(&web_content);
                            string_payload.push_str("\n"); 
                            sources.source_urls.push(url.clone())
                        }
                        Err(_) => {
                        }
                    }
                }
    
                for text in &upload_data_object.text_files {
                    string_payload.push_str(&text.title);
                    string_payload.push_str("\n"); 
                    string_payload.push_str(&text.content);
                    string_payload.push_str("\n"); 
                    sources.source_texts.push(text.clone())
                }
                
                let sanitized_title = lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone().replace(" ", "_");
                
                // File path of config.json
                let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
                
                // File path of target/output.md
                let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);
    
                if let Err(error) = std::fs::create_dir_all(&target_folder_path) {
                    crate::debug_print!("Failed to create folder: {}", error);
                }
    
                // TODO: loop through all lessons list and find ID to add
                let lessons = menu_data_object.lessons_data_object.lessons.clone();

                let mut i: u32 = 0;
                for lesson  in lessons {
                    i = lesson.id; 
                    i += 1;
                }
                
                let lesson = Lesson{
                    id: i,
                    sources,
                    target_path: target_folder_path.to_owned(),
                    title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone()
                };
                
                // TODO: Move inside write_lesson_to_config_file
                config_file_path.push_str("\\config.json");
    
                if let Err(error) = write_lesson_to_config_file(&lesson, &config_file_path) {
                    crate::debug_print!("Failed to write to config file: {}", error);
                }

                // Spwaning the thread for creating the lesson
                tokio::spawn(create_thread_handles());
                
                // if release {
                //     match lesson_generator::generate(string_payload) {
                //         Ok(md_content) => {
                //             // write to file here
                //             if let Err(error) = write_lesson_to_target_path(&md_content, &target_folder_path) {
                //                 crate::debug_print!("Failed to write to target file: {}", error);
                //             }

                //             response_message = ReadResponse {
                //                 status_code: StatusCode::OK.as_u16() as u32,
                //                 title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                //                 md_content,
                //                 error_string: String::from("No error")
                //             };
                //         }
                //         Err(error) => {
                //             response_message = ReadResponse {
                //                 status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                //                 title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                //                 md_content: String::from("No content"),
                //                 error_string: error.to_string()
                //             };
                //         }
                //     }
                //     // response_message = ReadResponse {
                //     //     status_code: StatusCode::OK.as_u16() as u32,
                //     //     title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                //     //     md_content: "MOVED LESSON GENERATION".to_string(),
                //     //     error_string: String::from("No error")
                //     // };
                // }
                // else {
                //     // write to file here
                //     if let Err(error) = write_lesson_to_target_path("Debug Mode: Dummy Content", &target_folder_path) {
                //         crate::debug_print!("Failed to write to target file: {}", error);
                //     }
                    
                //     response_message = ReadResponse {
                //         status_code: StatusCode::OK.as_u16() as u32,
                //         title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                //         md_content: "Debug Mode: Dummy Content".to_string(),
                //         error_string: String::from("No error")
                //     };
                // }
                
                
    
                // if response_message.status_code == StatusCode::OK.as_u16() as u32 {
                //     RustResponse {
                //         successful: true,
                //         message: Some(response_message.encode_to_vec()),
                //         blob: None,
                //     }
                // }
                // else {
                //     RustResponse {
                //         successful: false,
                //         message: Some(response_message.encode_to_vec()),
                //         blob: None,
                //     }
                // }   

                let response_message = ReadResponse {
                    status_code: StatusCode::OK.as_u16() as u32,
                    title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                    md_content: "MOVED LESSON GENERATION".to_string(), // TODO: Need to remove this from rinf
                    error_string: String::from("No error")
                };

                RustResponse {
                    successful: true,
                    message: Some(response_message.encode_to_vec()),
                    blob: None,
                }
            },
            RustOperation::Update => RustResponse::default(),
            RustOperation::Delete => RustResponse::default(),
        }
    }

    pub fn read_tcp_stream() -> Result<(), Box<dyn std::error::Error>> {
        use crate::messages::results::view_lesson_result::load_lesson::{StateSignal, ID};

        println!("Reading from tcp stream:");
        // Create a new ZeroMQ context
        let mut ctx = zmq::Context::new();
    
        // Create a REP socket and bind to the inproc endpoint
        let socket = ctx.socket(zmq::REP)?;
        
        if let Err(bind_err) = socket.bind("tcp://127.0.0.1:5555") {
            // Log the binding error
            crate::debug_print!("Error binding to socket: {}", bind_err);
            return Err(Box::new(bind_err) as Box<dyn std::error::Error>);
        }
        
        println!("Socket bound!");

        // Define a closure to receive messages
        // receives from lesson_generator.py
        let receive_message = || {
            socket.recv_bytes(0).map(|bytes| String::from_utf8(bytes))
        };
    
        // receive message from python loop
        loop {
            sleep(std::time::Duration::from_millis(50));
            // Receive a message
            let message = receive_message()??;
            
            crate::debug_print!("{}", message);

            
            // Do something with the message here 
            let signal_message = StateSignal { stream_message: message.to_owned() };
            let rust_signal = RustSignal {
                resource: ID,
                message: Some(signal_message.encode_to_vec()),
                blob: None,
            };
            send_rust_signal(rust_signal); // Send to flutter
            
            if message == "[LL_END_STREAM]" {
                // socket.send("EXIT_ACK", 0).unwrap();
                break;
            } 
            
            socket.send("ACK", 0).unwrap();
            // sends to lesson_generator.py
        }
        
        crate::debug_print!("loop broken");
        
        // Just to make sure that the socket is unbound for future operations.
        let _ = socket.unbind("tcp://127.0.0.1:5555");
        let _ = ctx.destroy();
    
        Ok(())
    }

    // runs the lesson_generation in python using a thread
    // runs streaming in different thread
    pub async fn create_thread_handles() {
        // Create a thread for reading inproc stream concurrently
        let stream_handle = std::thread::spawn(move || {
            let _ = read_tcp_stream();
            println!("Finished server thread.");
        });
    
        // Create a thread for generating the lesson
        let generation_handle = std::thread::spawn(move || {
            if let Err(err) = lesson_generator::generate_lesson_stream() {
                eprintln!("Error generating lesson stream: {}\n", err);
                // Handle the error as needed
            }
            println!("Finished generation thread.");
        });
    
        // Wait for the generation thread to finish
        generation_handle.join().unwrap();
        stream_handle.join().unwrap();
    
        println!("Finished.");
    }

    pub fn write_lesson_to_config_file(current_lesson: &Lesson, file_path: &str) -> std::io::Result<()> {
        // crate::debug_print!("Deserializing...");
    
        // Load all lessons in the config file and Deserialize the JSON string
        let mut root: Root = {
            // crate::debug_print!("Reading File: {}", file_path);
            let mut file = File::open(file_path)?;
            let mut contents = String::new();
            file.read_to_string(&mut contents)?;
    
            // Deserialize the JSON string into Root
            serde_json::from_str(&contents).unwrap_or_else(|e| {
                // Handle deserialization error, for simplicity, panicking in case of an error
                crate::debug_print!("Failed to deserialize Root.");
                panic!("Error deserializing Root: {}", e);
            })
        };
    
        // Append the current lesson to the lessons in the root
        root.menu_data_object.lessons_data_object.lessons.push(current_lesson.to_owned());
    
        // crate::debug_print!("Deserialized:");
        // for lesson in &root.menu_data_object.lessons_data_object.lessons {
        //     crate::debug_print!("{:#?}", lesson);
        // }
    
        // Serialize the root into JSON again
        let updated_json_string = serde_json::to_string_pretty(&root)?;
    
        // Truncate the config file
        let mut file = OpenOptions::new()
            .write(true)
            .truncate(true)
            .open(file_path)?;
    
        // Write the updated JSON string to the file
        file.write_all(updated_json_string.as_bytes())?;
    
        Ok(())
    }

    fn write_lesson_to_target_path(string_payload: &str, target_path: &str) -> std::io::Result<()> {
        /* Takes in string to write to the output.md and the target.path of the config
        */
        crate::debug_print!("Writing to target path...");

        let mut final_path: String = String::from(target_path);

        final_path.push_str("\\output.md");

        let mut file = OpenOptions::new()
            .write(true)
            .create(true)
            .truncate(true)
            .open(final_path)?;

        file.write_all(string_payload.as_bytes())?;    

        Ok(())
    }
}
