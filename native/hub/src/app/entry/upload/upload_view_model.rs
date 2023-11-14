use crate::bridge::send_rust_signal;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::entry::upload::upload_model::{UploadModel, TextFile};




// Handler functions
pub async fn handle_uploaded_content(rust_request: RustRequest,
    upload_model: &mut tokio::sync::MutexGuard<'_, UploadModel>) -> RustResponse {
    use crate::messages::entry::upload::uploaded_content::{CreateRequest, CreateResponse, ReadRequest, ReadResponse};

    match rust_request.operation {
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            // Do something with data
            upload_model.file_paths = request_message.file_paths;
            upload_model.urls = request_message.urls;
            upload_model.text_files = request_message.texts
                .into_iter()
                .map(|prost_text_file| crate::app::entry::upload::upload_model::TextFile {
                    title: prost_text_file.title,
                    content: prost_text_file.content,
                })
                .collect();

            let response_message;
            if upload_model.file_paths.len() > 0 {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: 200
                };
            }
            else {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: 404
                };
            }
            
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        },
        RustOperation::Read => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            // let response_message;
            let _ = request_message;

            let response_message = ReadResponse {
                file_paths: upload_model.file_paths.clone(),
                urls: upload_model.urls.clone(),
                texts: upload_model.text_files.clone()
                    .into_iter()
                    .map(|prost_text_file| uploaded_content::TextFile {
                        title: prost_text_file.title,
                        content: prost_text_file.content,
                    })
                    .collect()
            };
            
            // if request_message.req {
            // }
            // else {
            //     response_message = ReadResponse {
            //         file_paths: Vec::new(),
            //         urls: Vec::new(),
            //         texts: Vec::new()
            //     };
            // }

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