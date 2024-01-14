use http::StatusCode;
use serde::de::Error;
use crate::bridge::send_rust_signal;
use crate::app::entry::menu::menu_data_object::{Root, MenuDataObject};
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::menu::menu::UpdateRequest;
// use crate::messages::entry::menu::menu::CreateRequest;
// use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;
use std::io::{self, Write, Read};
use std::path::Path;

use crate::app::utils::lesson_generator;
use std::fs::{self, OpenOptions, create_dir_all, File};
use std::thread::sleep;


use crate::app::global_objects::lessons_data_object::{Lesson, LessonsDataObject};

pub async fn handle_lesson_open(rust_request: RustRequest,
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> RustResponse {
    use crate::messages::results::open_finished_lesson::open_lesson::{ReadRequest, ReadResponse, CreateRequest, CreateResponse, UpdateRequest, UpdateResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();
            
            let lesson_content = request_message.lesson_content;
            let lesson_id = request_message.lesson_id;
            let new_lesson_title = request_message.new_lesson_title;

            let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
            let config_file_path_temp = settings_save_directory_data_object.save_directory.clone();
            config_file_path.push_str("\\config.json");

            // let sanitized_title = lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone();
            // let sanitized_title = sanitized_title.split_at(8).1;

            // crate::debug_print!("Lesson Title: {}", sanitized_title);
            // let config_file_path = settings_save_directory_data_object.save_directory.clone();

            // // File path of target/output.md
            // let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);

            // match write_lesson_to_target_path(&lesson_content, &target_folder_path) {
            //     Ok(_) => {
            //         crate::debug_print!("Wrote to lesson target file path at {}", target_folder_path);
            //     }
            //     Err(error) => {
            //         crate::debug_print!("Failed to write lesson to target: {}", error);
            //         let response_message = CreateResponse{
            //             status_code: StatusCode::BAD_REQUEST.as_u16() as u32,
            //         };

            //         return RustResponse {
            //             successful: false,
            //             message: Some(response_message.encode_to_vec()),
            //             blob: None,
            //         }
            //     }
            // }
            
            match get_lesson_by_id(&config_file_path, lesson_id) {
                Ok(Some(lesson)) => {
                    // Found the lesson, do something with it
                    crate::debug_print!("{:#?}", lesson);
                    let target_folder_path = format!("{}\\{}", &config_file_path_temp, &lesson.title);
                    crate::debug_print!("{}", target_folder_path);
                    match write_lesson_to_target_path(&lesson_content, &target_folder_path) {
                        Ok(_) => {
                            crate::debug_print!("Wrote to lesson target file path at {}", target_folder_path);
                            if lesson.title != new_lesson_title {
                                let new_folder_name = format!("{}\\{}", &config_file_path_temp, &new_lesson_title);

                                match std::fs::rename(target_folder_path, new_folder_name) {
                                    Ok(_) => {
                                        crate::debug_print!("Renamed folder successfully!");
                                    },
                                    Err(error) => {
                                        crate::debug_print!("Failed to rename folder: {}", error);
                                    }
                                }
                                
                                match change_lesson_title_in_config_file(&config_file_path, lesson_id, new_lesson_title.as_str()){
                                    Ok(_) => {
                                        crate::debug_print!("Successfully updated config file!");
                                    }
                                    Err(error) => {
                                        crate::debug_print!("{}", error);
                                    }
                                }
                                // json
                            }
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

                    let response_message = CreateResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                    };
    
                    return RustResponse {
                        successful: true,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                }
                Ok(None) => {
                    // Lesson with the specified ID not found
                    crate::debug_print!("Lesson not found.");
                }
                Err(err) => {
                    // Handle the error
                    crate::debug_print!("Error: {}", err);
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
        }
        RustOperation::Read => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let lesson_id = request_message.id;
            
            let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
            let config_file_path_temp = settings_save_directory_data_object.save_directory.clone();
            config_file_path.push_str("\\config.json");

            match get_lesson_by_id(&config_file_path, lesson_id) {
                Ok(Some(lesson)) => {
                    // Found the lesson, do something with it
                    crate::debug_print!("{:#?}", lesson);
                    let target_folder_path = format!("{}\\{}", &config_file_path_temp, &lesson.title);
                    crate::debug_print!("{}", target_folder_path);
                    let content;
                    match read_lesson_from_target_path(target_folder_path.as_str()) {
                        Ok(result) => {
                            content = result
                        }
                        Err(error) => {
                            crate::debug_print!("{}", error);
                            content = "Error loading content".to_string();
                        }
                    }
                    let response_message = ReadResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                        title: lesson.title,
                        md_content: content, // TODO: Need to remove this from rinf
                        error_string: String::from("No error")
                    };
    
                    return RustResponse {
                        successful: true,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                }
                Ok(None) => {
                    // Lesson with the specified ID not found
                    crate::debug_print!("Lesson not found.");
                }
                Err(err) => {
                    // Handle the error
                    crate::debug_print!("Error: {}", err);
                }
            }

            let response_message = ReadResponse {
                status_code: StatusCode::OK.as_u16() as u32,
                title: "Temp".to_string(),
                md_content: "Temp".to_string(), // TODO: Need to remove this from rinf
                error_string: String::from("No error")
            };

            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Update => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = UpdateRequest::decode(message_bytes.as_slice()).unwrap();

            crate::debug_print!("Update called");

            let mut content_to_regenerate = request_message.content_to_regenerate;
            let additional_commands: String = request_message.additional_commands;
            let lesson_id = request_message.lesson_id;  

            let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
            let config_file_path_temp = settings_save_directory_data_object.save_directory.clone();
            config_file_path.push_str("\\config.json");
            // File path of target/output.md

            match get_lesson_by_id(&config_file_path, lesson_id) {
                Ok(Some(lesson)) => {
                    // Found the lesson, do something with it
                    crate::debug_print!("{:#?}", lesson);
                    let target_folder_path = format!("{}\\{}", &config_file_path_temp, &lesson.title);
                    crate::debug_print!("{}", target_folder_path);
                    crate::debug_print!("From update!");

                    tokio::spawn(create_regeneration_thread_handles(content_to_regenerate, additional_commands, target_folder_path));

                    let response_message = UpdateResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                    };
    
                    return RustResponse {
                        successful: true,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                }
                Ok(None) => {
                    // Lesson with the specified ID not found
                    crate::debug_print!("Lesson not found.");
                }
                Err(err) => {
                    // Handle the error
                    crate::debug_print!("Error: {}", err);
                }
            }

            // tokio::spawn(create_regeneration_thread_handles(content_to_regenerate, additional_commands, target_folder_path));

            let response_message = UpdateResponse {
                status_code: StatusCode::OK.as_u16() as u32,
            };

            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Delete => RustResponse::default()
    }

}

fn read_lesson_from_target_path(target_path: &str) -> std::io::Result<String> {
    /* Reads the content of output.md at the target path of the config */
    crate::debug_print!("Reading from target path...");

    let mut final_path: String = String::from(target_path);
    final_path.push_str("\\output.md");

    let mut file = OpenOptions::new().read(true).open(final_path)?;

    let mut content = String::new();
    file.read_to_string(&mut content)?;

    Ok(content)
}

pub fn get_lesson_by_id(file_path: &str, lesson_id: u32) -> std::io::Result<Option<Lesson>> {
    // Load all lessons in the config file and find the lesson with the specified ID
    let root: Root = {
        let mut file = File::open(file_path)?;
        let mut contents = String::new();
        file.read_to_string(&mut contents)?;

        serde_json::from_str(&contents).unwrap_or_else(|e| {
            crate::debug_print!("Failed to deserialize Root.");
            panic!("Error deserializing Root: {}", e);
        })
    };

    // Find the lesson with the specified ID
    let lesson = root
        .menu_data_object
        .lessons_data_object
        .lessons
        .iter()
        .find(|&l| l.id == lesson_id)
        .cloned(); // Clone the found lesson to return

    Ok(lesson)
}

fn change_lesson_title_in_config_file(file_path: &str, lesson_id: u32, new_title: &str) -> io::Result<()> {
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

    // Find the lesson with the given ID and update its title
    if let Some(lesson) = root.menu_data_object.lessons_data_object.lessons.iter_mut().find(|l| l.id == lesson_id) {
        lesson.title = new_title.to_string();

        let new_target_path = format!(
            "{}/{}",
            Path::new(&lesson.target_path).parent().unwrap().display(),
            new_title
        );
        lesson.target_path = new_target_path.clone();

        // Rename the folder if it exists
        if Path::new(&lesson.target_path).exists() {
            fs::rename(&lesson.target_path, &new_target_path)?;
        }
    } else {
        // Handle the case where the lesson with the given ID is not found
        return Err(io::Error::new(io::ErrorKind::NotFound, "Lesson not found"));
    }

    // Serialize the updated MenuDataObject back to JSON
    let updated_json = serde_json::to_string_pretty(&root)?;

    // Overwrite the content of the JSON file with the updated JSON string
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(file_path)?;
    file.write_all(updated_json.as_bytes())?;

    Ok(())
}


pub fn read_tcp_stream() -> Result<(), Box<dyn std::error::Error>> {
    use crate::messages::results::open_finished_lesson::open_lesson::{StateSignal, ID};

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

        crate::debug_print!("Sending to dart!");
        // Do something with the message here 
        let signal_message = StateSignal { stream_message: message.to_owned() };
        let rust_signal = RustSignal {
            resource: ID,
            message: Some(signal_message.encode_to_vec()),
            blob: None,
        };
        send_rust_signal(rust_signal); // Send to flutter
        crate::debug_print!("Done sending to dart!");
        
        if message == "[LL_END_STREAM]" {
            // socket.send("EXIT_ACK", 0).unwrap();
            break;
        } 
        
        crate::debug_print!("Sending ACK!");
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
pub async fn create_regeneration_thread_handles(content_to_regenerate: String, additional_instructions: String, index_path: String) {
    // Create a thread for reading inproc stream concurrently
    let stream_handle = std::thread::spawn(move || {
        let _ = read_tcp_stream();
        println!("Finished server thread.");
    });

    // Create a thread for generating the lesson
    let generation_handle = std::thread::spawn(move || {
        if let Err(err) = lesson_generator::regenerate_lesson_stream(content_to_regenerate, additional_instructions, index_path) {
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