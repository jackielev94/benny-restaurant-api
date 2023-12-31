create table reservations (
  id uuid not null default uuid_generate_v4(),
    constraint _pk_reservations
    primary key (id),
  start_time smallint not null,
  end_time smallint not null,
  open boolean not null default true,
  table_configuration_id uuid not null,
    constraint _fk_reservations_table_configuration_id
    foreign key (table_configuration_id)
    references table_configurations
);
