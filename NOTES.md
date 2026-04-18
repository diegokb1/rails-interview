To run this project in docker, run:
`docker build -t rails-interview . `
`docker run -p 3000:3000 rails-interview`

`all_sessions.json` contains the AI conversation
# High-Level Overview:

The project consists of two main modules: 
  - the UI part, where the user can easily see the lists and items. The user can also create, edit and delete lists and items.
  - The pure API module, which is used to comunicate with external services

Both use different controllers and endpoints but with similar logic.
Sidekiq was used for background jobs related to syncing records. This takes care of performance since the app is not blocked during syncing. The drawback is that we lose control for example if redis is not working properly and the job does not get executed.

When a user modifies a record via the UI, a sync job is triggered to call the external API to do the same. If the call returns a 200 result, the local records have a "last_synced" column that is updated and have an "external_id" column that gets updated with the external API id for mapping. If the external call returns an error, it is logged for debugging purposes

When a record is created via the API, if an error occurs, said error is also logged.

For external call, httparty was used.

Unit tests were added to make sure the controllers, jobs and services work as intended. This was needed since no real tests can be made for syncing.

# Key Design Decisions:
- Like metioned above: two modules where implemented. Two different controllers namespaces where implemented since the UI and the api are considered two different things and it didn't make sense using same controller.
- For basic front end design, I used Bootstrap since it's pretty much straight forward to use. Tailwind was also considered but was discarded since I didn't want to end up with long classes for a simple app.
- Sidekiq with Redis was used to handle background jobs since it's easy to set up and also it already provides retries support in case the jobs fail.
- To sync records, a service for each action was created, then, those services enqueue background jobs. Each service and job were separated in two modules each: one for lists and one for items. This was done to keep the code clean instead of having a lot of services and jobs with similar names in same folder.
- Although httparty was used for making external calls, an api client module was created so the jobs don't depend directly on it. This way, if we want to change libary, we only need to change it in one place. The api client was also split into list and items modules
- To reduce possible sync erros even further, a general sync job was created so it checks old records (records that have been synced more than a week ago) with the external API and if there is any mismatch in data, the local records get created, updated or deleted.

# Resilience and Error Handling:
For error handling, proper error messaging was implented for the API and error displayed was added for the UI. Also, instead of the app crashing due to a 404 or 500 error, a custom view is shown instead of the app crashing.
## Syncing error cases handling:
When successfully creating or updating a record locally and an error happens in the queue, the job will contiune to retry 25 times (default sidekiq config). If the job is porperly sent, but an error ocurrs in the external end, we will have logging data with correct id and/or params to examine and take proper action. If a record is delted locally but not externally, the sync job will delete the local record.
If a record is created or updated externaly but not locally, the loggind data will be recorded. If the record is deleted externally but not locally, the sync job will also take care of it.

# Areas for Improvement:
- Since it's a simple system with records with few columns, the UI can be a SPA using accordion to expand list items and updating name and description in the same page. Working this way will require taking into consideration having a lot of lists with a lot of items that can make performance to be an issue.
- When using the UI to mark all tasks as completed, hotwire is used to show the result without reloading the whole page. The main issue is that with current implementation, if we have a lot of items, it can still take some time to update all items. Another approach could have been a background job that marks all tasks as completed. The drawback with this is that we still need to reload the page to see the results.
- Pagination can be used to improve queries and avoid showing a lot of lists and items if they are too much.
- Indexes can be added for example with "external_id" to improve performance when reading data from the external API.
- When bulk completing tasks, a lot of requests are sent to the external API. Although it's a background job, if a bulk update was present in external API, it could be called once instead of having multiple calls.
- The system id and external hardcoded url need to be in a env var
- A model like ListError and ItemError could be added for better quering the errors and making decisions more easily. The records could be regualry deleted to avoid keeping a lot of these records.

# Assumptions:
- The API is used only by the external API so that's why it uses external_id for queries and that's why it does not call sync services for any case.
- Similar to the local system, the external API has some sort of webhook or call that comunicates with the local app.
- The external call does not acually work since the url is not defined.
- The external API is considered as the source of truth, that's why for the general sync job, any record that does not exist externaly is deleted.
- The general sync job is already scheduled to run every week (can be edited) via Jenkins or any other system the app is hosted