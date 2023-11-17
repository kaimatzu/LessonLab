use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;

use crate::app::utils::{scrapers, lesson_generator};
use crate::app::entry::upload::upload_model::UploadModel;
use crate::app::lesson::lesson_specifications_model::LessonSpecificationsModel;
use crate::app::results::lesson_result_model::LessonResultModel;

// Handler functions
pub async fn handle_lesson_generation(rust_request: RustRequest,
    upload_model: &mut tokio::sync::MutexGuard<'_, UploadModel>,
    lesson_specifications_model: &mut tokio::sync::MutexGuard<'_, LessonSpecificationsModel>) -> RustResponse {
    use crate::messages::results::view_lesson_result::load_lesson::{ReadRequest, ReadResponse};

    match rust_request.operation {
        RustOperation::Create => RustResponse::default(),
        RustOperation::Read => {
            // Handles the lesson generation
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let _ = request_message;

            let response_message;

            let mut string_payload: String = String::new();
            
            string_payload.push_str("Lesson Specifications \n");

            for lesson_specification in &lesson_specifications_model.lesson_specifications {
                string_payload.push_str(&lesson_specification);
                string_payload.push_str("\n"); 
            }

            string_payload.push_str("------------------------------- \n");

            for file_path in &upload_model.file_paths {
                if file_path.to_lowercase().ends_with(".pdf") {
                    // TODO: Implement other scrapers for other text file formats
                    match scrapers::scrape_pdf(file_path.to_string()) {
                        Ok(pdf_content) => {
                            string_payload.push_str(&pdf_content);
                            string_payload.push_str("\n"); 
                        }
                        Err(_) => {
                        }
                    }
                }
            }

            for url in &upload_model.urls {
                match scrapers::scrape_url(url.to_string()) {
                    Ok(web_content) => {
                        string_payload.push_str(&web_content);
                        string_payload.push_str("\n"); 
                    }
                    Err(_) => {
                    }
                }
            }

            for text in &upload_model.text_files {
                string_payload.push_str(&text.title);
                string_payload.push_str("\n"); 
                string_payload.push_str(&text.content);
                string_payload.push_str("\n"); 
            }

            match lesson_generator::generate(string_payload){
                Ok(md_content) => {
                    response_message = ReadResponse {
                        status_code: StatusCode::OK.as_u16() as u32,
                        md_content: md_content
                    };
                }
                Err(_) => {
                    response_message = ReadResponse {
                        status_code: StatusCode::NOT_FOUND.as_u16() as u32,
                        md_content: String::from("No content")
                    };
                }
            }
            
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