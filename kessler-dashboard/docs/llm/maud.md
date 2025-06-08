
Axum

Axum support is available with the "axum" feature:

This adds an implementation of IntoResponse for Markup/PreEscaped<String>. This then allows you to use it directly as a response!

```rs
use maud::{html, Markup};
use axum::{Router, routing::get};

async fn hello_world() -> Markup {
    html! {
        h1 { "Hello, World!" }
    }
}

#[tokio::main]
async fn main() {
    // build our application with a single route
    let app = Router::new().route("/", get(hello_world));

    // run it with hyper on localhost:3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();

    axum::serve(listener, app.into_make_service()).await.unwrap();
}
```

Partials

Maud does not have a built-in concept of partials or sub-templates. Instead, you can compose your markup with any function that returns Markup.

The following example defines a header and footer function. These functions are combined to form the final page.

use maud::{DOCTYPE, html, Markup};

/// A basic header with a dynamic `page_title`.
fn header(page_title: &str) -> Markup {
    html! {
        (DOCTYPE)
        meta charset="utf-8";
        title { (page_title) }
    }
}

/// A static footer.
fn footer() -> Markup {
    html! {
        footer {
            a href="rss.atom" { "RSS Feed" }
        }
    }
}

/// The final Markup, including `header` and `footer`.
///
/// Additionally takes a `greeting_box` that's `Markup`, not `&str`.
pub fn page(title: &str, greeting_box: Markup) -> Markup {
    html! {
        // Add the header markup to the page
        (header(title))
        h1 { (title) }
        (greeting_box)
        (footer())
    }
}

Using the page function will return the markup for the whole page. Here's an example:

page("Hello!", html! {
    div { "Greetings, Maud." }
});




Elements and attributes
Elements with contents: p {}

Write an element using curly braces:

html! {
    h1 { "Poem" }
    p {
        strong { "Rock," }
        " you are a rock."
    }
}

Void elements: br;

Terminate a void element using a semicolon:

html! {
    link rel="stylesheet" href="poetry.css";
    p {
        "Rock, you are a rock."
        br;
        "Gray, you are gray,"
        br;
        "Like a rock, which you are."
        br;
        "Rock."
    }
}

The result will be rendered with HTML syntax – <br> not <br />.
Custom elements and data attributes

Maud also supports elements and attributes with hyphens in them. This includes custom elements, data attributes, and ARIA annotations.

html! {
    article data-index="12345" {
        h1 { "My blog" }
        tag-cloud { "pinkie pie pony cute" }
    }
}

Non-empty attributes: title="yay"

Add attributes using the syntax: attr="value". You can attach any number of attributes to an element. The values must be quoted: they are parsed as string literals.

html! {
    ul {
        li {
            a href="about:blank" { "Apple Bloom" }
        }
        li class="lower-middle" {
            "Sweetie Belle"
        }
        li dir="rtl" {
            "Scootaloo "
            small { "(also a chicken)" }
        }
    }
}

Empty attributes: checked

Declare an empty attribute by omitting the value.

html! {
    form {
        input type="checkbox" name="cupcakes" checked;
        " "
        label for="cupcakes" { "Do you like cupcakes?" }
    }
}

Before version 0.22.2, Maud required a ? suffix on empty attributes: checked?. This is no longer necessary (#238), but still supported for backward compatibility.
Classes and IDs: .foo #bar

Add classes and IDs to an element using .foo and #bar syntax. You can chain multiple classes and IDs together, and mix and match them with other attributes:

html! {
    input #cannon .big.scary.bright-red type="button" value="Launch Party Cannon";
}

In Rust 2021, the # symbol must be preceded by a space, to avoid conflicts with reserved syntax:

html! {
    // Works on all Rust editions
    input #pinkie;

    // Works on Rust 2018 and older only
    input#pinkie;
}

The classes and IDs can be quoted. This is useful for names with numbers or symbols which otherwise wouldn't parse:

html! {
    div."col-sm-2" { "Bootstrap column!" }
}

Implicit div elements

If the element name is omitted, but there is a class or ID, then it is assumed to be a div.

html! {
    #main {
        "Main content!"
        .tip { "Storing food in a refrigerator can make it 20% cooler." }
    }
}


Splices and toggles
Splices: (foo)

Use (foo) syntax to insert the value of foo at runtime. Any HTML special characters are escaped by default.

let best_pony = "Pinkie Pie";
let numbers = [1, 2, 3, 4];
html! {
    p { "Hi, " (best_pony) "!" }
    p {
        "I have " (numbers.len()) " numbers, "
        "and the first one is " (numbers[0])
    }
}

Arbitrary Rust code can be included in a splice by using a block. This can be helpful for complex expressions that would be difficult to read otherwise.

html! {
    p {
        ({
            let f: Foo = something_convertible_to_foo()?;
            f.time().format("%H%Mh")
        })
    }
}

Splices in attributes

Splices work in attributes as well.

let secret_message = "Surprise!";
html! {
    p title=(secret_message) {
        "Nothing to see here, move along."
    }
}

To concatenate multiple values within an attribute, wrap the whole thing in braces. This syntax is useful for building URLs.

const GITHUB: &'static str = "https://github.com";
html! {
    a href={ (GITHUB) "/lambda-fairy/maud" } {
        "Fork me on GitHub"
    }
}

Splices in classes and IDs

Splices can also be used in classes and IDs.

let name = "rarity";
let severity = "critical";
html! {
    aside #(name) {
        p.{ "color-" (severity) } { "This is the worst! Possible! Thing!" }
    }
}

What can be spliced?

You can splice any value that implements Render. Most primitive types (such as str and i32) implement this trait, so they should work out of the box.

To get this behavior for a custom type, you can implement the Render trait by hand. The PreEscaped wrapper type, which outputs its argument without escaping, works this way. See the traits section for details.

use maud::PreEscaped;
let post = "<p>Pre-escaped</p>";
html! {
    h1 { "My super duper blog post" }
    (PreEscaped(post))
}

Toggles: [foo]

Use [foo] syntax to show or hide classes and boolean attributes on a HTML element based on a boolean expression foo.

Toggle boolean attributes:

let allow_editing = true;
html! {
    p contenteditable[allow_editing] {
        "Edit me, I "
        em { "dare" }
        " you."
    }
}

And classes:

let cuteness = 95;
html! {
    p.cute[cuteness > 50] { "Squee!" }
}

Optional attributes with values: title=[Some("value")]

Add optional attributes to an element using attr=[value] syntax, with square brackets. These are only rendered if the value is Some<T>, and entirely omitted if the value is None.

html! {
    p title=[Some("Good password")] { "Correct horse" }

    @let value = Some(42);
    input value=[value];

    @let title: Option<&str> = None;
    p title=[title] { "Battery staple" }
}

