use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
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

            let response_message;
            if settings_save_directory_model.save_directory.len() > 0 {
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
        }

        RustOperation::Read => RustResponse::default(),
        RustOperation::Update => RustResponse::default(),
        RustOperation::Delete => RustResponse::default(),
    }
    
}
