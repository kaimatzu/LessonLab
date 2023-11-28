pub mod lesson_result_data_handlers {
    use http::StatusCode;
    use crate::app::settings::settings_data_object::SettingsDataObject;
    use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
    use crate::messages::entry::upload::uploaded_content;
    use prost::Message;
    use tokio_with_wasm::tokio;
    
    use std::fs::{OpenOptions, create_dir_all, File};
    use std::io::{self, Write, Read};
    
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
        settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>) -> RustResponse {
        use crate::messages::results::view_lesson_result::load_lesson::{ReadRequest, ReadResponse};
        
        // TODO: MAKE THIS GLOBAL
        let release = true; // DEBUG MODE
    
        match rust_request.operation {
            RustOperation::Create => RustResponse::default(),
            RustOperation::Read => {
                // Handles the lesson generation
                let message_bytes = rust_request.message.unwrap();
                let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
    
                let _ = request_message;
    
                let response_message;
    
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
                            Err(_) => {
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
    
                if release {
                    match lesson_generator::generate(string_payload) {
                        Ok(md_content) => {
                            // write to file here
                            

                            response_message = ReadResponse {
                                status_code: StatusCode::OK.as_u16() as u32,
                                title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                                md_content,
                                error_string: String::from("No error")
                            };
                        }
                        Err(error) => {
                            response_message = ReadResponse {
                                status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                                title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                                md_content: String::from("No content"),
                                error_string: error.to_string()
                            };
                        }
                    }
                }
                else {
                    response_message = ReadResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                        title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone(),
                        md_content: "Debug Mode: Dummy Content".to_string(),
                        error_string: String::from("No error")
                    };
                }
                
                let sanitized_title = lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone().replace(" ", "_");
                
                // File path of config.json
                let mut config_file_path = settings_save_directory_data_object.save_directory.clone();
                
                let target_folder_path = format!("{}\\{}", &config_file_path, &sanitized_title);
    
                if let Err(error) = std::fs::create_dir_all(&target_folder_path) {
                    crate::debug_print!("Failed to create folder: {}", error);
                }
    
                let lesson = Lesson{
                    sources,
                    target_path: target_folder_path,
                    title: lesson_specifications_data_object.lesson_specifications.get(0).unwrap().clone()
                };
                
                config_file_path.push_str("\\config.json");
    
                if let Err(error) = write_lesson_to_config_file(&lesson, &config_file_path) {
                    crate::debug_print!("Failed to write to file: {}", error);
                }
    
                if response_message.status_code == StatusCode::OK.as_u16() as u32 {
                    RustResponse {
                        successful: true,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                }
                else {
                    RustResponse {
                        successful: false,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                }   
            },
            RustOperation::Update => RustResponse::default(),
            RustOperation::Delete => RustResponse::default(),
        }
    }
    
    pub fn write_lesson_to_config_file(current_lesson: &Lesson, file_path: &str) -> std::io::Result<()> {
        crate::debug_print!("Deserializing...");
    
        // Load all lessons in the config file and Deserialize the JSON string
        let mut existing_lessons: LessonsDataObject = {
            crate::debug_print!("Reading File: {}", file_path);
            let mut file = File::open(file_path)?;
            let mut contents = String::new();
            file.read_to_string(&mut contents)?;
    
            // Deserialize the JSON string into Lessons
            serde_json::from_str(&contents).unwrap_or_else(|e| {
                // Handle deserialization error, for simplicity, panicking in case of an error
                crate::debug_print!("Failed to deserialize lessons.");
                panic!("Error deserializing lessons: {}", e);
            })
        };
    
        existing_lessons.create_lesson(current_lesson.to_owned());
    
        crate::debug_print!("Deserialized:");
        for lesson in &existing_lessons.lessons {
            crate::debug_print!("{:#?}", lesson);
        }
        
        // Combine the current lessons into the array of lessons
        // existing_lessons.lessons.extend_from_slice(current_lessons.lessons.as_slice());
    
        // Serialize the combined array into JSON again
        let updated_json_string = serde_json::to_string_pretty(&existing_lessons)?;
    
        // runcate the config file
        let mut file = OpenOptions::new()
            .write(true)
            .truncate(true)
            .open(file_path)?;
    
        // Write the updated JSON string to the file
        file.write_all(updated_json_string.as_bytes())?;
    
        Ok(())
    }
}
