use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::quiz::quiz_specifications_data_object::QuizSpecificationsDataObject;
use crate::messages::quiz::quiz_specifications::{CreateRequest, CreateResponse, ReadRequest, ReadResponse, UpdateResponse, DeleteResponse};

pub async fn handle_quiz_specifications(rust_request: RustRequest,
    quiz_specifications_data_object: &mut tokio::sync::MutexGuard<'_, QuizSpecificationsDataObject>) -> RustResponse {

    match rust_request.operation {
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            // save in main for persistent data
            // will be used in quiz_page_handler for quiz generation later
            quiz_specifications_data_object.quiz_specifications = request_message.quiz_specifications;

            let response_message;
            if quiz_specifications_data_object.quiz_specifications.len() > 0 {
                response_message = CreateResponse {
                    status_code: StatusCode::OK.as_u16() as u32
                };
            } else {
                response_message = CreateResponse {
                    status_code: StatusCode::NOT_FOUND.as_u16() as u32
                };
            }
            
            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Read => {
            RustResponse {
                successful: false,
                message: Some(ReadResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32, quiz_specifications: todo!() }.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Update => {
            RustResponse {
                successful: false,
                message: Some(UpdateResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32}.encode_to_vec()),
                blob: None,
            }
        }
        RustOperation::Delete => {
            RustResponse {
                successful: false,
                message: Some(DeleteResponse{status_code: StatusCode::NOT_IMPLEMENTED.as_u16() as u32}.encode_to_vec()),
                blob: None,
            }
        }
    }
}