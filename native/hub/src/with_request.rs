//! This module runs the corresponding function
//! when a `RustRequest` was received from Dart
//! and returns a `RustResponse`.

// Data handlers
use crate::app::entry::menu::menu_data_handlers::*;
use crate::app::entry::upload::upload_sources_data_handlers::*;
use crate::app::lesson::lesson_specifications_data_handlers::*;
use crate::app::quiz::quiz_specifications_data_handlers::*;
use crate::app::quiz::quiz_page_data_handlers::*;
use crate::app::results::lesson_result_data_handlers::*;
use crate::app::settings::settings_data_handlers::*;

// Data objects
use crate::app::entry::menu::menu_data_object::MenuDataObject;
use crate::app::entry::menu::menu_data_handlers::menu_data_handlers::*;
use crate::app::entry::upload::upload_sources_data_handlers::upload_sources_data_handlers::*;
use crate::app::lesson::lesson_specifications_data_handlers::lesson_specifications_data_handlers::*;
use crate::app::open_lesson::lesson_open_data_handlers::lesson_open_data_handlers::handle_lesson_open;
use crate::app::results::lesson_result_data_handlers::lesson_result_data_handlers::*;
use crate::app::settings::settings_data_handlers::settings_data_handlers::*;
use crate::app::lesson::lesson_specifications_data_object::LessonSpecificationsDataObject;
use crate::app::quiz::quiz_specifications_data_object::QuizSpecificationsDataObject;
use crate::app::quiz::quiz_page_data_object::QuizPageDataObject;
use crate::app::settings::settings_data_object::SettingsDataObject;

use crate::bridge::{RustRequestUnique, RustResponse, RustResponseUnique};
use crate::messages;
use crate::app;

use tokio_with_wasm::tokio;
use app::entry::upload::upload_sources_data_object::UploadSourcesDataObject;

pub async fn handle_request(request_unique: RustRequestUnique,
    menu_data_object: &mut tokio::sync::MutexGuard<'_, MenuDataObject>,
    upload_sources_data_object: &mut tokio::sync::MutexGuard<'_, UploadSourcesDataObject>,
    lesson_specifications_data_object: &mut tokio::sync::MutexGuard<'_, LessonSpecificationsDataObject>,
    settings_save_directory_data_object: &mut tokio::sync::MutexGuard<'_, SettingsDataObject>,
    quiz_specifications_data_object: &mut tokio::sync::MutexGuard<'_, QuizSpecificationsDataObject>) -> RustResponseUnique {
    // Get the request data from Dart.
    let rust_request = request_unique.request;
    let interaction_id = request_unique.id;

    // Run the function that handles the Rust resource.
    let rust_resource = rust_request.resource;
    let rust_response = match rust_resource {
        messages::entry::menu::menu::ID => {
            handle_menu_content_loading(rust_request, menu_data_object, settings_save_directory_data_object).await
        }
        messages::entry::upload::uploaded_content::ID => { // Handle Uploaded File content
            handle_uploaded_content(rust_request, upload_sources_data_object).await
        }
        messages::lesson::lesson_specifications::ID => {
            handle_lesson_specifications(rust_request, lesson_specifications_data_object).await
        }
        messages::results::view_lesson_result::load_lesson::ID => {
            handle_lesson_generation(rust_request,
                upload_sources_data_object,
                lesson_specifications_data_object,
                settings_save_directory_data_object,
                menu_data_object).await
        }
        messages::results::open_finished_lesson::open_lesson::ID => {
            handle_lesson_open(rust_request, save_directory_model, menu_data_object).await
        }
        messages::settings::save_directory::ID =>{
            handle_choose_directory(rust_request, settings_save_directory_data_object).await
        }
        messages::quiz::quiz_specifications::ID => {
            handle_quiz_specifications(rust_request, quiz_specifications_data_object).await
        }
        messages::quiz::quiz_page::ID => {
            handle_quiz_generation(rust_request,
                upload_sources_data_object,
                quiz_specifications_data_object,
                settings_save_directory_data_object,
                menu_data_object).await
        }
        _ => RustResponse::default(),
    };

    // Return the response to Dart.
    RustResponseUnique {
        id: interaction_id,
        response: rust_response,
    }
}