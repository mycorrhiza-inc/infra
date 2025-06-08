I would try to organize this project into 3 main components, inspired by how nextjs organizes its projects, namely it has an 

`src/app` folder that handles the routes and top level return functions for the app

`src/components` which handles most of the html creation and template rendering, and can also handle logic specific to a particular component

`src/lib` for either logic that is complicated enough to split off from a component, or is shared across components

As for other features I want:

I want a sidebar that displays different pages, for the beginning this should include a:

- Dashboard
(Later this will include a high level overview, but now will just be the same as the status page)
- Service Statuses
This page will go ahead and hit the following service endpoints 

kessler.xyz
api.kessler.xyz
nightly.kessler.xyz
nightly-api.kessler.xyz
http://quickwit-main
http://kessler-postgres 
openscrapers.kessler.xyz 
openscrapers-airflow.kessler.xyz


And see if it gets back any results for those services as a status dashboard.


- About 
Just a simple about page. You can leave it blank for now.


Use HTMX so that when you are switching between tasks on the sidebar it only is changing the main html body.
