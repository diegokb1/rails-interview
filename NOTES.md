# High-Level Overview:

The project consists of two main modules: 
  - the UI part, where the user can easily see the lists and items. The user can also create, edit and delete lists and items.
  - The pure API module, which is used to comunicate with external services

Both use different controllers and endpoints but with similar logic.
Sidekiq was used for background jobs related to syncing records.

When a user modifies a record via the UI, a sync job is triggered to call the external API to do the same. If the call returns a 200 result, the local records have a "last_synced" column that is updated. If the external call returns an error, it is logged for debugging purposes
When a record is created via the API, if an error occurs, said error is also logged.

For external call, httparty was used.

# Key Design Decisions:
- Like metioned above: two modules where implemented. Two different controllers namespaces where implemented since the UI and the api are considered two different things and it didn't make sense using same controller.
- For basic front end design, I used Bootstrap since it's pretty much straight forward to use. Tailwind was also considered but was discarded since I didn't want to end up with long classes for a simple app.
- Sidekiq with Redis was used to handle background jobs since it's easy to set up and also it already provides retries support in case the jobs fail.
- To sync records, a service for each action was created, then, those services enqueue background jobs. Each service and job were separated in two modules each: one for lists and one for items. This was done to keep the code clean instead of having a lot of services and jobs with similar names in same folder.
- Although httparty was used for making external calls, an api client module was created so the jobs don't depend directly on it. This way, if we want to change libary, we only need to change it in one place. The api client was also split into list and items modules
- To reduce possible sync erros even further, a general sync job was created so it checks old records (records that have been synced more than a week ago) with the external API and if there is any mismatch in data, the local records get created, updated or deleted.

# Resilience and Error Handling:

# Areas for Improvement:

# Assumptions: