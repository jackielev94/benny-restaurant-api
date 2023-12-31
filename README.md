# Restaurant Reservations API

Small application to create restaurant reservations built with TypeScript, Node, Express, and a Postgres Database.

## Instructions

In order to run the application locally, complete the following steps:
* Set up a postgres database locally (in your psql shell run ```create database <insert your db name here>;``` you might also need to run ```create extension if not exists "uuid-ossp";``` - these commands are located in ```index.sql```), and run the sql scripts in the following order: ```restaurants.sql```, ```table_configurations.sql```, ```reservations.sql```
* Seed a couple of restaurants with desired open and close times to get started i.e. ```insert into restaurants (open_time, close_time) values (18, 22);```
* Create a ```.env``` file at the root of the repo with your pg connection string as an environment variable ```PG_CONN=<insert your pgconn here in the format PG_CONN=postgres://<username>:<password>@<server>/<databasename>>```
* Run ```npm install``` to install all required dependencies
* At this point, you should be able to run ```npm run dev``` to start the application on your local host, at which point you can hit the following endpoints:
  - First upload some table configurations by hitting ```POST /table-configurations```. Take a look at ```/types/express/creatTableConfiguration``` to see the body format
  - Now you can try making a reservation by hitting ```PUT /reservations```. Take a look at ```/types/express/creatReservation``` to see the body format
  - Finally, you can get a list of open reservations for a particular restaurant by hitting ```GET /restaurants/:restaurantId/open-reservations```
* If you'd like to run the tests, you can do so by running ```npm run test```. Please keep in mind in order to do this, you'll need enough available reservations open that match the test data. I'd suggest uploading 20 table configurations indoors and with 3 seats in order to make sure you don't run into any issues. Whenever you re-run the tests, just run ```update reservations set open = true``` in your database to reopen all reservations. Of course there are better ways to handle this, but for sake of time, I kept everything pointing to the one database and didn't clean up the db between tests.

## Approach and Trade-offs

I took the following steps in working through this project:
* Design a database schema for a simple reservation system for a single day of reservations
* Map out the urls, request params/bodies and response bodies for each of the three required endpoints
* Create a TypeScript Node Express server to ensure strict typing and a simple setup
* Scaffold out the types, routes, service layer, and data provider layer
* Add service logic for uploading a table configuration (which also creates all available reservations for those tables for a single day) and booking a reservation (which checks for the best open reservation that fits request)
* Test functionality of routes and service layer

Trade-offs:
* Booking a reservation: I thought a lot about the database design for the reservations and table configurations. At first, I thought about only creating a reservation once it was booked, and using a join between table configurations and reservations to see what was available, but that started to seem tricky with the time slots. What seemed easier was to create the full day of reservations when a table configuration is uploaded based on restaurant open and close time with each reservation having an open flag. Then I was able to easily filter open reservations with a SQL clause. The downside here is that we have a nested loop when uploading table configurations. Say we upload 10 table configurations. Then we'd have to create reservations for each of those 10 tables for each timeslot based on restaurant open and close time. If we think forward to making reservations for more than a single day, we'd have to do that for multiple days. However, this is still a limited set. Even large restaurants will have a limited number of tables, and we may not need to create reservations for more than a month ahead, so while this will take some time to loop over, it's still reasonable. But if we wanted huge restaurant groups (say Union Square Hospitality group) to be able to upload multiple configs for multiple restaurants for years ahead, this could become time consuming and we may have to reconsider. We could probably optimize by doing a bulk db insert, and somehow optimizing the time slot issue (maybe automatically have the timeslots for each table config increase by 2 at the db level).
* Allocation-based system: In the real world, more of an allocation-based system would be ideal, where a reservation isn't directly tied to a table. For this approach, there could be a rules engine, which would dynamically assess current reservations versus table configurations with the right requirements, and of course take walk-ins into consideration. That way the reservations are made with some wiggle room for the restaurant in the moment to assign tables based on availability, but also doesn't max them out. While this approach is probably more "correct", it seemed overly complex for the purposes of the assignment, but definitely worth calling out.
* Dates/Times: For ease and sake of time, I decided to use integers between 1 and 24 to indicate restaurant open and close times as well as reservation start and end times. This way, I didn't have to worry about working with timestamps, especially since I was only dealing with a single day of reservations.
* Testing: I am very new to unit testing. We don't do it at my company (big yikes!) and so I have almost no experience writing tests in a production environment. I used ```jest```, but didn't deal with mocking at all. I just pointed to the same database and didn't clean/re-seed between tests. But, I was able to test all 3 routes and some of the service logic. Of course with more time I'd clean this up and add more testing!
* Error handling: With more time, I'd add specific error handling for Database errors, Axios errors, etc.
* General: I think in general, the data models and code allow for easy expansion. For example, the data models can be built out (i.e. a restaurant needs a name, location, etc., reservations need people attached, etc.). The CRUD functionality for each object can be easily built within the provided structure. The restaurant open and close times as well as reservation start times can be turned into timestamps and manipulated with the help of a library like ```moment.js```. I could see creating some sort of lambda function that runs once a month or whenever is desireable to upload the next month's reservations for all table configurations... etc.
