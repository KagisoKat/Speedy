BEGIN;

INSERT INTO salons (name, phone, email, address)
VALUES ('Speedy Beauty Salon', '0123456789', 'hello@speedy.local', 'Johannesburg')
ON CONFLICT DO NOTHING;

COMMIT;
