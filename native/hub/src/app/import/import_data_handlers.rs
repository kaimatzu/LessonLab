use http::StatusCode;
use crate::app::entry::menu::menu_data_object::MenuDataObject;
use crate::app::global_objects::lessons_data_object::Lesson;
use crate::app::results::lesson_result_data_handlers::write_lesson_to_config_file;
use crate::app::settings::settings_data_object::SettingsDataObject;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use tokio_with_wasm::tokio;

use std::fs::{self, File, rename};
use std::io::{self, Read, Write, Error as IoError};
use std::path::{Path, PathBuf};
use zip_extensions::read::ZipArchiveExtensions;
// use zip::read::ZipArchive;
// use zip::CompressionMethod;

pub async fn handle_import_lesson(rust_request: RustRequest, 
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>) -> RustResponse {
    use crate::messages::import::import_material::{CreateRequest, CreateResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            let file_path = request_message.file_path;
            let folder_name = request_message.folder_name;
            let config_file_path = settings_save_directory_data_object.save_directory.clone();

            // File path of target/output.md
            let target_folder_path = format!("{}\\{}", &config_file_path, &folder_name);

            crate::debug_print!("Target import path: {}", target_folder_path);
            crate::debug_print!("Full path: {}", file_path);

            let lessons = menu_data_object.lessons_data_object.lessons.clone();

            let mut i: u32 = 0;
            for lesson  in lessons {
                i = lesson.id; 
                i += 1;
            }
            
            let lesson = Lesson{
                id: i,
                // sources,
                target_path: target_folder_path.to_owned(),
                title: folder_name.split_at(folder_name.len() - 5).0.to_string(),
            };
            
            let mut temp_config_file_path = config_file_path.clone();
            temp_config_file_path.push_str("\\config.json");

            if let Err(error) = write_lesson_to_config_file(&lesson, &temp_config_file_path) {
                crate::debug_print!("Failed to write to config file: {}", error);
            }

            match decompress_lesson_file(file_path.as_str(), &target_folder_path) {
                Ok(_) => {
                    crate::debug_print!("Directory '{}' created successfully.", file_path);
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
                    crate::debug_print!("Error in creating directory: {}", error);

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

fn decompress_lesson_file(input_file: &str, output_folder: &str) -> io::Result<()> {
    crate::debug_print!("input file {}", input_file);
    crate::debug_print!("output folder {}", output_folder);

    let output_folder = output_folder.split_at(output_folder.len() - 5).0;

    let file = File::open(input_file)?;
    let mut archive = zip::ZipArchive::new(file)?;
    archive.extract(&output_folder)?;

    Ok(())
}