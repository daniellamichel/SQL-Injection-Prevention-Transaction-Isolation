START TRANSACTION;
ISOLATION LEVEL REPEATABLE READ;
update RentalPlans
set max_movies=100
where name='rental plus';
SELECT * from RentalPlans;
COMMIT;