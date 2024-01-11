
// Handler functions
use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::lesson::lesson_specifications_data_object::LessonSpecificationsDataObject;

pub async fn handle_lesson_specifications(rust_request: RustRequest,
    lesson_specifications_data_object: &mut tokio::sync::MutexGuard<'_, LessonSpecificationsDataObject>) -> RustResponse {
    use crate::messages::lesson::lesson_specifications::{CreateRequest, CreateResponse, ReadRequest, ReadResponse};

    match rust_request.operation {
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = CreateRequest::decode(message_bytes.as_slice()).unwrap();

            lesson_specifications_data_object.lesson_specifications = request_message.lesson_specifications;

            let response_message;
            if lesson_specifications_data_object.lesson_specifications.len() > 0 {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::OK.as_u16() as u32
                };
            } else {
                response_message = CreateResponse {
                    // Send the data back in a response
                    status_code: StatusCode::BAD_REQUEST.as_u16() as u32
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
                lesson_specifications: lesson_specifications_data_object.lesson_specifications.clone()
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

