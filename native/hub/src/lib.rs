use bridge::respond_to_dart;
use tokio_with_wasm::tokio;
use tokio_with_wasm::tokio::sync::{Mutex};
use with_request::handle_request;
use std::any::Any;
use std::sync::{Arc, MutexGuard};

use app::entry::upload::upload_model::{UploadModel, TextFile};
use app::lesson::lesson_specifications_model::{self, LessonSpecificationsModel};
use app::settings::settings_save_directory_model::SaveDirectoryModel;

mod bridge;
mod messages;
mod app;
mod with_request;

/// This `hub` crate is the entry point for the Rust logic.
/// Always use non-blocking async functions such as `tokio::fs::File::open`.
async fn main() {
    let upload_model = Arc::new(Mutex::new(UploadModel::default()));
    let lesson_specifications_model = Arc::new(Mutex::new(LessonSpecificationsModel::default()));
    let settings_save_directory_model = Arc::new(Mutex::new(SaveDirectoryModel::default()));
    // This is `tokio::sync::mpsc::Reciver` that receives the requests from Dart.
    let mut request_receiver = bridge::get_request_receiver();

    // Repeat `tokio::spawn` anywhere in your code
    // if more concurrent tasks are needed.
    while let Some(request_unique) = request_receiver.recv().await {
        // Clone the Arc<Mutex<UploadModel>> for each handler function call
        let upload_model_clone = Arc::clone(&upload_model);
        let lesson_specifications_model_clone = Arc::clone(&lesson_specifications_model);
        let save_directory_model_clone = Arc::clone(&settings_save_directory_model);

        tokio::spawn(async move {
            // Use lock() to obtain a tokio::sync::MutexGuard
            let mut upload_model_guard = upload_model_clone.lock().await; 
            let mut lesson_specifications_guard = lesson_specifications_model_clone.lock().await;
            let mut save_directory_guard = save_directory_model_clone.lock().await;

            let response_unique = handle_request(
                request_unique, 
                &mut upload_model_guard,
                &mut lesson_specifications_guard,
                &mut save_directory_guard).await;
            respond_to_dart(response_unique);
        });
    }
}
