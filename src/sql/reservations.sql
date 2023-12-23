create table reservations (
  id uuid not null default uuid_generate_v4(),
    constraint _pk_reservations
    primary key (id),
  start_time time not null,
  end_time time not null,
  table_configuration_id uuid not null,
    constraint _fk_reservations_table_configuration_id
    foreign key (table_configuration_id)
    references table_configurations
);