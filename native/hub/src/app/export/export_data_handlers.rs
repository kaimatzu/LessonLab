use http::StatusCode;
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use tokio_with_wasm::tokio;

use std::fs::{self, File};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use serde::{Serialize, Deserialize};
use zip::ZipWriter;
use zip_extensions::write::ZipWriterExtensions;
// use bincode;

// Define a struct to represent the data you want to serialize
#[derive(Serialize, Deserialize)]
struct FolderData {
    // Add fields for the data you want to store
    // For example, you might want to store file names and contents
    files: Vec<(String, Vec<u8>)>,
}
pub async fn handle_export_lesson(rust_request: RustRequest, settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,) -> RustResponse {
    use crate::messages::export::export_material_as_custom_type::{CreateRequest, CreateResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();
            let config_file_path = settings_save_directory_data_object.save_directory.clone();

            
            let file_path = request_message.file_path;
            match create_lesson_file(file_path.as_str(), &config_file_path) {
                Ok(_) => {
                    crate::debug_print!("Custom file '{}' created successfully.", file_path);
                    let response_message = CreateResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                    };

                    return RustResponse {
                        successful: true,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                },
                Err(error) => {
                    crate::debug_print!("Error in creating custom file: {}", error);

                    let response_message = CreateResponse {
                        status_code: StatusCode::BAD_REQUEST.as_u16() as u32,
                    };

                    return RustResponse {
                        successful: false,
                        message: Some(response_message.encode_to_vec()),
                        blob: None,
                    }
                },
            }
        },
        RustOperation::Read=> RustResponse::default(),
        RustOperation::Update => RustResponse::default(),
        RustOperation::Delete => RustResponse::default()
    }
}

fn create_lesson_file(full_path: &str, config_file_path: &str) -> io::Result<()> {
    // Convert the input path to a PathBuf to handle Windows paths
    let full_path = PathBuf::from(full_path);
    // Extract the folder path and file name
    let (folder_path, file_name) = match (full_path.parent(), full_path.file_name()) {
        (Some(folder), Some(name)) => (folder, name),
        _ => return Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid path")),
    };
    let target_folder_path = format!("{}\\{}", &config_file_path, &file_name.to_str().unwrap_or_default());
    let target_folder_path = target_folder_path.split_at(target_folder_path.len() - 5).0;

    crate::debug_print!("folder name: {}", folder_path.to_str().unwrap_or_default());
    crate::debug_print!("file name: {}", file_name.to_str().unwrap_or_default());
    crate::debug_print!("target path name: {}", target_folder_path);

    let file = File::create(full_path)?;
    let mut zip = ZipWriter::new(file);

    let created = PathBuf::from(target_folder_path);
    zip.create_from_directory(&created)?;

    
    Ok(())
}
