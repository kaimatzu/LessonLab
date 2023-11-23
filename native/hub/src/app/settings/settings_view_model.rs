use std::fs::{OpenOptions, create_dir_all, File};
use std::fs;
use std::io::{self, Write};

use http::StatusCode;
use crate::app::results::lesson_result_model::Lessons;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::settings::settings_save_directory_model::SaveDirectoryModel;

pub async fn handle_choose_directory(rust_request: RustRequest,
    settings_save_directory_model: &mut tokio::sync::MutexGuard<'_, SaveDirectoryModel>) -> RustResponse{
    use crate::messages::settings::save_directory::{CreateRequest, CreateResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();
        
            // Do something with data
            settings_save_directory_model.save_directory = request_message.save_directory;
        
            let mut file_path = settings_save_directory_model.save_directory.clone();
            file_path.push_str("\\config.json");
        
            let response_message;
            if settings_save_directory_model.save_directory.len() > 0 {
                if !file_exists(&file_path) || file_is_empty(&file_path) {
                    // If the file doesn't exist or is empty, create it
                    let lessons = Lessons::default();
                    let result = generate_config_file(&lessons, file_path.as_str());
                    match result {
                        Ok(_) => {
                            crate::debug_print!("Success in creating/opening config file!");
                            crate::debug_print!("At: {}", settings_save_directory_model.save_directory);
                        }
                        Err(error) => {
                            crate::debug_print!("Failed to write to/load file: {}", error);
                        }
                    }
                }
        
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::OK.as_u16() as u32,
                };
            } else {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                };
            }
        
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        }
        

        RustOperation::Read => RustResponse::default(),
        RustOperation::Update => RustResponse::default(),
        RustOperation::Delete => RustResponse::default(),
    }
    
}

/* Creates a new config file
 */
pub fn generate_config_file(lessons: &Lessons, file_path: &str) -> std::io::Result<()> {
    let json_string = serde_json::to_string_pretty(lessons)?;
    let file = OpenOptions::new()
                    .read(true)
                    .write(true)
                    .create(true)
                    .truncate(true)  
                    .open(file_path);
    match file {
        Ok(mut file) => {
            file.write_all(json_string.as_bytes())?;
            drop(file);
        },

        Err(error) => {
            crate::debug_print!("Error in writing to file: '{}'.", error);
            crate::debug_print!("At: {}", file_path);
        }
    }
    Ok(())
}

fn file_exists(file_path: &str) -> bool {
    fs::metadata(file_path).is_ok()
}

fn file_is_empty(file_path: &str) -> bool {
    if let Ok(metadata) = fs::metadata(file_path) {
        metadata.len() == 0
    } else {
        false
    }
}