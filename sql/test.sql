insert into Sessions (created_user_id, start_time, end_time) Values (1, CURRENT_TIMESTAMP, '2025-01-06 19:00:00');

insert into SessionDrinks (session_id, drink_id, quantity, start_time, end_time) values (1, 5, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

insert into SessionDrinks (session_id, drink_id, quantity, start_time, end_time) values (1, 6, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
