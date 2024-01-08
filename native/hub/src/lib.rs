use bridge::respond_to_dart;
use messages::quiz::quiz_specifications;
use tokio_with_wasm::tokio;
use tokio_with_wasm::tokio::sync::Mutex;
use with_request::handle_request;
use std::sync::Arc;

use app::entry::menu::menu_data_object::MenuDataObject;
use app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;
use app::lesson::lesson_specifications_data_object::LessonSpecificationsDataObject;
use app::quiz::quiz_specifications_data_object::QuizSpecificationsDataObject;
use app::settings::settings_data_object::SettingsDataObject;

mod bridge;
mod messages;
mod app;
mod with_request;

/// This `hub` crate is the entry point for the Rust logic.
/// Always use non-blocking async functions such as `tokio::fs::File::open`.
async fn main() {
    let menu_data_object = Arc::new(Mutex::new(MenuDataObject::default()));
    let upload_sources_data_object = Arc::new(Mutex::new(UploadSourcesDataObject::default()));
    let lesson_specifications_data_object = Arc::new(Mutex::new(LessonSpecificationsDataObject::default()));
    let settings_save_directory_data_object = Arc::new(Mutex::new(SettingsDataObject::default()));
    let quiz_specifications_data_object = Arc::new(Mutex::new(QuizSpecificationsDataObject::default()));
    // This is `tokio::sync::mpsc::Reciver` that receives the requests from Dart.
    let mut request_receiver = bridge::get_request_receiver();

    // Repeat `tokio::spawn` anywhere in your code
    // if more concurrent tasks are needed.
    while let Some(request_unique) = request_receiver.recv().await {
        // Clone the Arc<Mutex<UploadSourcesDataObject>> for each handler function call
        let menu_data_object_clone = Arc::clone(&menu_data_object);
        let upload_sources_data_object_clone = Arc::clone(&upload_sources_data_object);
        let lesson_specifications_data_object_clone = Arc::clone(&lesson_specifications_data_object);
        let save_directory_data_object_clone = Arc::clone(&settings_save_directory_data_object);
        let quiz_specifications_data_object_clone = Arc::clone(&quiz_specifications_data_object);

        tokio::spawn(async move {
            // Use lock() to obtain a tokio::sync::MutexGuard
            let mut menu_data_object_guard = menu_data_object_clone.lock().await;
            let mut upload_sources_data_object_guard = upload_sources_data_object_clone.lock().await; 
            let mut lesson_specifications_data_object_guard = lesson_specifications_data_object_clone.lock().await;
            let mut save_directory_data_object_guard = save_directory_data_object_clone.lock().await;
            let mut quiz_specifications_data_object_guard = quiz_specifications_data_object_clone.lock().await;

            let response_unique = handle_request(
                request_unique, 
                &mut menu_data_object_guard,
                &mut upload_sources_data_object_guard,
                &mut lesson_specifications_data_object_guard,
                &mut save_directory_data_object_guard,
                &mut quiz_specifications_data_object_guard).await;
            respond_to_dart(response_unique);
        });
    }
}
