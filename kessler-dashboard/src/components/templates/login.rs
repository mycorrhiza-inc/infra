use maud::{Markup, html};
use crate::components::templates::global::GlobalInfo;

/// Login page template
pub fn login(next: Option<&str>) -> Markup {
    let info = GlobalInfo {
        title: "Login".to_string(),
        user_info: None,
    };
    super::base(
        &info,
        html! {
            div class="card w-96 mx-auto bg-base-100 shadow-xl" {
                div class="card-body" {
                    h2 class="card-title" { "User Login" }
                    form method="post" class="space-y-4" {
                        div class="form-control" {
                            label class="label" for="username" {
                                span class="label-text" { "Username" }
                            }
                            input type="text" name="username" id="username"
                                class="input input-bordered" required value="";
                        }
                        div class="form-control" {
                            label class="label" for="password" {
                                span class="label-text" { "Password" }
                            }
                            input type="password" name="password" id="password"
                                class="input input-bordered" required;
                        }
                        div class="form-control mt-6" {
                            input type="submit" value="Login" class="btn btn-primary";
                        }
                        @if let Some(next_val) = next {
                            input type="hidden" name="next" value=(next_val);
                        }
                    }
                }
            }
        },
    )
}