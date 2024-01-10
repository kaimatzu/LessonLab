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


use crate::app::global_objects::lessons_data_object::{Lesson, LessonsDataObject};

pub async fn handle_lesson_open(rust_request: RustRequest,
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> RustResponse {
    use crate::messages::results::open_finished_lesson::open_lesson::{ReadRequest, ReadResponse, UpdateRequest, UpdateResponse};

    match rust_request.operation{
        RustOperation::Create => RustResponse::default(),
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
        RustOperation::Update => RustResponse::default(),
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
    
