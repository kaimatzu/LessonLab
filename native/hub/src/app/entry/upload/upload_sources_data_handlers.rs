
// Handler functions
use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;

pub async fn handle_uploaded_content(rust_request: RustRequest,
    upload_sources_data_object: &mut tokio::sync::MutexGuard<'_, UploadSourcesDataObject>) -> RustResponse {
    use crate::messages::entry::upload::uploaded_content::{CreateRequest, CreateResponse, ReadRequest, ReadResponse};

    match rust_request.operation {
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            // Do something with data
            upload_sources_data_object.file_paths = request_message.file_paths;
            upload_sources_data_object.urls = request_message.urls;
            upload_sources_data_object.text_files = request_message.texts
                .into_iter()
                .map(|prost_text_file| crate::app::entry::upload::upload_sources_data_object::TextFile {
                    title: prost_text_file.title,
                    content: prost_text_file.content,
                })
                .collect();

            let response_message;
            if upload_sources_data_object.file_paths.len() > 0 {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::OK.as_u16() as u32
                };
            }
            else {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::NOT_FOUND.as_u16() as u32
                };
            }
            
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Read => {
            // Debug purposes. Just to check if the uploaded files are stored in main().
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let _ = request_message;

            let response_message = ReadResponse {
                file_paths: upload_sources_data_object.file_paths.clone(),
                urls: upload_sources_data_object.urls.clone(),
                texts: upload_sources_data_object.text_files.clone()
                    .into_iter()
                    .map(|prost_text_file| uploaded_content::TextFile {
                        title: prost_text_file.title,
                        content: prost_text_file.content,
                    })
                    .collect()
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

