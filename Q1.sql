START TRANSACTION;
UPDATE RentalPlans 
SET fee = fee - 1
WHERE name = 'basic';

UPDATE RentalPlans
SET fee = fee + 1
WHERE name = 'prime';
COMMIT;