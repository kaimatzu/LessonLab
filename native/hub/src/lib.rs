use bridge::respond_to_dart;
use tokio_with_wasm::tokio;
use tokio_with_wasm::tokio::sync::{Mutex};
use with_request::handle_request;
use std::sync::{Arc};
use app::entry::upload::upload_model::{UploadModel, TextFile};

mod bridge;
mod messages;
mod app;
mod with_request;

/// This `hub` crate is the entry point for the Rust logic.
/// Always use non-blocking async functions such as `tokio::fs::File::open`.
async fn main() {
    let upload_model = Arc::new(Mutex::new(UploadModel {
        // initialize your fields here
        file_paths: Vec::new(),
        urls: Vec::new(),
        text_files: Vec::new(),
    }));

    // This is `tokio::sync::mpsc::Reciver` that receives the requests from Dart.
    let mut request_receiver = bridge::get_request_receiver();

    // Repeat `tokio::spawn` anywhere in your code
    // if more concurrent tasks are needed.
    while let Some(request_unique) = request_receiver.recv().await {
        // Clone the Arc<Mutex<UploadModel>> for each handler function call
        let upload_model_clone = Arc::clone(&upload_model);
        
        tokio::spawn(async move {
            // Use lock() to obtain a tokio::sync::MutexGuard
            let mut upload_model_guard = upload_model_clone.lock().await; 

            let response_unique = handle_request(request_unique, &mut upload_model_guard).await;
            respond_to_dart(response_unique);
        });
    }
}
