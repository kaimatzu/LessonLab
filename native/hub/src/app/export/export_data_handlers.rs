use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use tokio_with_wasm::tokio;

use std::fs::{self, File};
use std::path::{Path, PathBuf};
use std::io::{self, Write};
use zip::write::FileOptions;

pub async fn handle_export_lesson(rust_request: RustRequest) -> RustResponse {
    use crate::messages::export::export_material_as_custom_type::{CreateRequest, CreateResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            let file_path = request_message.file_path;
            match create_lesson_file(file_path.as_str()) {
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

fn create_lesson_file(full_path: &str) -> io::Result<()> {
    // Convert the input path to a PathBuf to handle Windows paths
    let full_path = PathBuf::from(full_path);

    // Extract the folder path and file name
    let (folder_path, file_name) = match (full_path.parent(), full_path.file_name()) {
        (Some(folder), Some(name)) => (folder, name),
        _ => return Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid path")),
    };

    // Create a .lesson file
    let file = File::create(&full_path)?;

    // Create a zip archive with default compression
    let mut zip = zip::ZipWriter::new(file);
    let options = FileOptions::default().compression_method(zip::CompressionMethod::Stored);

    // Iterate through the folder and add files to the archive
    for entry in fs::read_dir(folder_path)? {
        let entry = entry?;
        let entry_path = entry.path();

        // Skip directories
        if entry_path.is_dir() {
            continue;
        }

        // Create an entry in the zip file
        let zip_path = entry_path.file_name().unwrap().to_string_lossy().into_owned();

        zip.start_file(zip_path, options)?;

        // Read the file and write its contents to the zip archive
        let file_content = fs::read(&entry_path)?;
        zip.write_all(&file_content)?;
    }

    Ok(())
}
