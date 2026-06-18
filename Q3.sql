START TRANSACTION;
UPDATE RentalPlans
SET fee = 39.99
WHERE name = 'prime';

UPDATE RentalPlans
SET fee = 9.99
WHERE name = 'basic';

COMMIT;