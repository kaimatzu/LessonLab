use http::StatusCode;
use crate::bridge::{RustOperation, RustRequest, RustResponse, RustSignal};
use crate::messages::entry::upload::uploaded_content;
use prost::Message;
use tokio_with_wasm::tokio;
use crate::app::lesson::settings_save_file_path_model::SaveFilePathModel;

pub async fn handle_save_file_path(rust_request: RustRequest,
    settings_save_file_path_model: &mut tokio::sync::MutexGuard<'_, SaveFilePathModel>) -> RustResponse{
    use crate::messages::setings::save_file_path::save_file::{ReadRequest, ReadResponse};

    match rust_request.operation{
        RustOperation::Create => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();
        }
       


    }
    
}
