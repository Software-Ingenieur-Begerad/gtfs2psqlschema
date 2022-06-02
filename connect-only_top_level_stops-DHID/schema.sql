DROP TABLE IF EXISTS agency CASCADE;
CREATE TABLE agency
(
  agency_id              text UNIQUE NULL,
  agency_name            text NOT NULL,
  agency_url             text NOT NULL,
  agency_timezone        text NOT NULL,
  agency_lang            text NULL,
  agency_phone           text NULL
);

DROP TABLE IF EXISTS stops CASCADE;
CREATE TABLE stops
(
  stop_id                text PRIMARY KEY,
  stop_code              text NULL,
  stop_name              text NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  stop_desc              text NULL,
  stop_lat               double precision NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  stop_lon               double precision NULL CHECK (location_type >= 0 AND location_type <= 2 AND stop_name IS NOT NULL OR location_type > 2),
  location_type          integer NULL CHECK (location_type >= 0 AND location_type <= 4),
  parent_station         text NULL CHECK (location_type IS NULL OR location_type = 0 OR location_type = 1 AND parent_station IS NULL OR location_type >= 2 AND location_type <= 4 AND parent_station IS NOT NULL),
  wheelchair_boarding    integer NULL CHECK (wheelchair_boarding >= 0 AND wheelchair_boarding <= 2 OR wheelchair_boarding IS NULL),
  platform_code          text NULL,
  zone_id                text NULL
);

DROP TABLE IF EXISTS routes CASCADE;
CREATE TABLE routes
(
  route_id               text PRIMARY KEY,
  agency_id              text NULL REFERENCES agency(agency_id) ON DELETE CASCADE ON UPDATE CASCADE,
  route_short_name       text NULL,
  route_long_name        text NULL CHECK (route_short_name IS NOT NULL OR route_long_name IS NOT NULL),
  route_type             integer NOT NULL,
  route_color            text NULL CHECK (route_color ~ $$[a-fA-F0-9]{6}$$ OR route_color = ''),
  route_text_color       text NULL CHECK (route_color ~ $$[a-fA-F0-9]{6}$$ OR route_color = ''),
  route_desc             text NULL
);

DROP TABLE IF EXISTS trips CASCADE;
CREATE TABLE trips
(
  route_id               text NOT NULL REFERENCES routes ON DELETE CASCADE ON UPDATE CASCADE,
  service_id             text NOT NULL,
  trip_id                text NOT NULL PRIMARY KEY,
  trip_headsign          text NULL,
  trip_short_name        text NULL,
  direction_id           boolean NULL,
  block_id               text NULL,
  shape_id               text NULL,
  wheelchair_accessible  integer NULL CHECK (wheelchair_accessible >= 0 AND wheelchair_accessible <= 2),
  bikes_allowed          integer NULL CHECK (bikes_allowed >= 0 AND bikes_allowed <= 2)
);

DROP TABLE IF EXISTS stop_times CASCADE;
CREATE TABLE stop_times
(
  trip_id                text NOT NULL REFERENCES trips ON DELETE CASCADE ON UPDATE CASCADE,
  arrival_time           interval NULL,
  departure_time         interval NOT NULL,
  stop_id                text NOT NULL REFERENCES stops ON DELETE CASCADE ON UPDATE CASCADE,
  stop_sequence          integer NOT NULL CHECK (stop_sequence >= 0),
  pickup_type            integer NOT NULL CHECK (pickup_type >= 0 AND pickup_type <= 3),
  drop_off_type          integer NOT NULL CHECK (drop_off_type >= 0 AND drop_off_type <= 3),
  stop_headsign          text NULL
);

DROP TABLE IF EXISTS calendar CASCADE;
CREATE TABLE calendar
(
  service_id             text PRIMARY KEY,
  monday                 boolean NOT NULL,
  tuesday                boolean NOT NULL,
  wednesday              boolean NOT NULL,
  thursday               boolean NOT NULL,
  friday                 boolean NOT NULL,
  saturday               boolean NOT NULL,
  sunday                 boolean NOT NULL,
  start_date             numeric(8) NOT NULL,
  end_date               numeric(8) NOT NULL
);

DROP TABLE IF EXISTS calendar_dates CASCADE;
CREATE TABLE calendar_dates
(
  service_id             text NOT NULL,
  date                   numeric(8) NOT NULL,
  exception_type         integer NOT NULL CHECK (exception_type >= 1 AND exception_type <= 2)
);

DROP TABLE IF EXISTS shapes CASCADE;
CREATE TABLE shapes
(
  shape_id               text NOT NULL,
  shape_pt_lat           double precision NOT NULL,
  shape_pt_lon           double precision NOT NULL,
  shape_pt_sequence      integer NOT NULL CHECK (shape_pt_sequence >= 0)
);

DROP TABLE IF EXISTS frequencies CASCADE;
CREATE TABLE frequencies
(
  trip_id                text NOT NULL REFERENCES trips ON DELETE CASCADE ON UPDATE CASCADE,
  start_time             interval NOT NULL,
  end_time               interval NOT NULL,
  headway_secs           integer NOT NULL CHECK (headway_secs >= 0),
  exact_times            boolean NULL
);

DROP TABLE IF EXISTS transfers CASCADE;
CREATE TABLE transfers
(
  from_stop_id           text NOT NULL REFERENCES stops(stop_id) ON DELETE CASCADE ON UPDATE CASCADE,
  to_stop_id             text NOT NULL REFERENCES stops(stop_id) ON DELETE CASCADE ON UPDATE CASCADE,
  transfer_type          integer NOT NULL CHECK (transfer_type >= 0 AND transfer_type <= 3),
  min_transfer_time      integer NULL CHECK (min_transfer_time >= 0),
  from_route_id          text NULL,
  to_route_id            text NULL,
  from_trip_id           text NULL,
  to_trip_id             text NULL
);

\COPY agency FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/agency.txt' (FORMAT CSV, HEADER)
\COPY stops FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/stops.txt' (FORMAT CSV, HEADER)
\COPY routes FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/routes.txt' (FORMAT CSV, HEADER)
\COPY trips FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/trips.txt' (FORMAT CSV, HEADER)
\COPY stop_times FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/stop_times.txt' (FORMAT CSV, HEADER)
\COPY calendar FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/calendar.txt' (FORMAT CSV, HEADER)
\COPY calendar_dates FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/calendar_dates.txt' (FORMAT CSV, HEADER)
\COPY shapes FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/shapes.txt' (FORMAT CSV, HEADER)
\COPY frequencies FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/frequencies.txt' (FORMAT CSV, HEADER)
\COPY transfers FROM '/home/begerad/begerad-nc-swingbe-de/connect-fahrplanauskunft/april-27-2022/pxypihdrpv_connect-only_top_level_stops-DHID/transfers.txt' (FORMAT CSV, HEADER)
