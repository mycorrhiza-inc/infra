use crate::components::templates::global::GlobalInfo;
use maud::{Markup, html};

/// Full admin page (wraps partial in base layout)
pub fn admin_full(info: &GlobalInfo) -> Markup {
    super::base(info, admin_partial(info))
}

/// Admin panel partial (for htmx boost)
pub fn admin_partial(info: &GlobalInfo) -> Markup {
    let username = &info.user_info.as_ref().unwrap().username;
    html! {
        div class="space-y-6" {
            div class="flex items-center justify-between" {
                h1 class="text-3xl font-bold" { "Welcome, " (username) "!" }
            }

            div class="grid grid-cols-1 md:grid-cols-3 gap-4" {
                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "Recent Activity" }
                        ul class="space-y-2" {
                            li { "User login: 5 minutes ago" }
                            li { "Settings updated" }
                            li { "New user registered" }
                        }
                    }
                }

                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "System Health" }
                        div class="radial-progress text-success" style="--value:85;" { "85%" }
                        p class="text-sm" { "All systems operational" }
                    }
                }

                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "Quick Actions" }
                        div class="flex flex-col gap-2" {
                            button class="btn btn-primary" { "Create New User" }
                            button class="btn btn-secondary" { "View Logs" }
                            button class="btn btn-accent" { "System Settings" }
                        }
                    }
                }
            }
        }
    }
}
