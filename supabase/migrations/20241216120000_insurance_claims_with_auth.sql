-- Location: supabase/migrations/20241216120000_insurance_claims_with_auth.sql
-- Insurance Claims Management System with Authentication

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'adjuster', 'customer');
CREATE TYPE public.claim_status AS ENUM ('draft', 'submitted', 'under_review', 'pending_docs', 'approved', 'denied', 'processing_payment', 'completed', 'cancelled');
CREATE TYPE public.damage_severity AS ENUM ('minor', 'moderate', 'major', 'total_loss');
CREATE TYPE public.vehicle_type AS ENUM ('car', 'truck', 'motorcycle', 'suv', 'van', 'other');

-- 2. Core Tables

-- User profiles table (intermediary for auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'customer'::public.user_role,
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Insurance policies table
CREATE TABLE public.insurance_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_holder_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    policy_number TEXT NOT NULL UNIQUE,
    policy_type TEXT NOT NULL,
    coverage_amount DECIMAL(12,2) NOT NULL,
    deductible_amount DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles table
CREATE TABLE public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    policy_id UUID REFERENCES public.insurance_policies(id) ON DELETE SET NULL,
    vehicle_type public.vehicle_type DEFAULT 'car'::public.vehicle_type,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    vin TEXT UNIQUE,
    license_plate TEXT,
    color TEXT,
    current_mileage INTEGER,
    estimated_value DECIMAL(12,2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Insurance claims table
CREATE TABLE public.insurance_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_number TEXT NOT NULL UNIQUE,
    policy_id UUID REFERENCES public.insurance_policies(id) ON DELETE RESTRICT,
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE RESTRICT,
    claimant_id UUID REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
    adjuster_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    status public.claim_status DEFAULT 'draft'::public.claim_status,
    incident_date TIMESTAMPTZ NOT NULL,
    reported_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    incident_location TEXT NOT NULL,
    incident_description TEXT NOT NULL,
    police_report_number TEXT,
    estimated_damage_amount DECIMAL(12,2),
    approved_amount DECIMAL(12,2),
    deductible_amount DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Damage assessments table (AI generated and manual)
CREATE TABLE public.damage_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    assessor_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    assessment_type TEXT DEFAULT 'ai_generated', -- 'ai_generated', 'manual', 'combined'
    severity public.damage_severity DEFAULT 'minor'::public.damage_severity,
    damage_description TEXT NOT NULL,
    affected_areas JSONB, -- Array of vehicle parts affected
    repair_recommendations TEXT,
    estimated_cost DECIMAL(10,2),
    confidence_score DECIMAL(3,2), -- For AI assessments (0.00 to 1.00)
    is_final BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Claim images table
CREATE TABLE public.claim_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    assessment_id UUID REFERENCES public.damage_assessments(id) ON DELETE SET NULL,
    uploaded_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    image_name TEXT NOT NULL,
    image_size INTEGER,
    image_type TEXT,
    description TEXT,
    is_primary BOOLEAN DEFAULT false,
    metadata JSONB, -- EXIF data, GPS coordinates, etc.
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Claim timeline/activity table
CREATE TABLE public.claim_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    activity_type TEXT NOT NULL, -- 'status_change', 'comment', 'document_upload', 'assessment_added'
    description TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_insurance_policies_holder ON public.insurance_policies(policy_holder_id);
CREATE INDEX idx_insurance_policies_number ON public.insurance_policies(policy_number);
CREATE INDEX idx_vehicles_owner ON public.vehicles(owner_id);
CREATE INDEX idx_vehicles_policy ON public.vehicles(policy_id);
CREATE INDEX idx_insurance_claims_claimant ON public.insurance_claims(claimant_id);
CREATE INDEX idx_insurance_claims_status ON public.insurance_claims(status);
CREATE INDEX idx_insurance_claims_number ON public.insurance_claims(claim_number);
CREATE INDEX idx_insurance_claims_incident_date ON public.insurance_claims(incident_date);
CREATE INDEX idx_damage_assessments_claim ON public.damage_assessments(claim_id);
CREATE INDEX idx_claim_images_claim ON public.claim_images(claim_id);
CREATE INDEX idx_claim_activities_claim ON public.claim_activities(claim_id);

-- 4. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.damage_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_activities ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions for RLS Policies

-- Check if user has admin role
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

-- Check if user has adjuster role or higher
CREATE OR REPLACE FUNCTION public.is_adjuster_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() 
    AND up.role IN ('admin'::public.user_role, 'manager'::public.user_role, 'adjuster'::public.user_role)
)
$$;

-- Check if user owns a claim
CREATE OR REPLACE FUNCTION public.owns_claim(claim_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.insurance_claims ic
    WHERE ic.id = claim_uuid AND ic.claimant_id = auth.uid()
)
$$;

-- Check if user is assigned as adjuster to a claim
CREATE OR REPLACE FUNCTION public.is_assigned_adjuster(claim_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.insurance_claims ic
    WHERE ic.id = claim_uuid AND ic.adjuster_id = auth.uid()
)
$$;

-- Check if user can access claim (owner, adjuster, or admin)
CREATE OR REPLACE FUNCTION public.can_access_claim(claim_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT (
    public.owns_claim(claim_uuid) OR
    public.is_assigned_adjuster(claim_uuid) OR
    public.is_adjuster_or_admin()
)
$$;

-- Check if user owns a policy
CREATE OR REPLACE FUNCTION public.owns_policy(policy_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.insurance_policies ip
    WHERE ip.id = policy_uuid AND ip.policy_holder_id = auth.uid()
)
$$;

-- Check if user owns a vehicle
CREATE OR REPLACE FUNCTION public.owns_vehicle(vehicle_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.vehicles v
    WHERE v.id = vehicle_uuid AND v.owner_id = auth.uid()
)
$$;

-- 6. RLS Policies

-- User profiles: Users can view/edit own profile, admins can view all
CREATE POLICY "users_own_profile" ON public.user_profiles
FOR ALL TO authenticated
USING (auth.uid() = id OR public.is_admin())
WITH CHECK (auth.uid() = id OR public.is_admin());

-- Insurance policies: Policy holders and admins can access
CREATE POLICY "policy_access" ON public.insurance_policies
FOR ALL TO authenticated
USING (public.owns_policy(id) OR public.is_adjuster_or_admin())
WITH CHECK (public.owns_policy(id) OR public.is_adjuster_or_admin());

-- Vehicles: Vehicle owners and admins can access
CREATE POLICY "vehicle_access" ON public.vehicles
FOR ALL TO authenticated
USING (public.owns_vehicle(id) OR public.is_adjuster_or_admin())
WITH CHECK (public.owns_vehicle(id) OR public.is_adjuster_or_admin());

-- Insurance claims: Claimants, assigned adjusters, and admins can access
CREATE POLICY "claim_access" ON public.insurance_claims
FOR ALL TO authenticated
USING (public.can_access_claim(id))
WITH CHECK (public.can_access_claim(id));

-- Damage assessments: Same as claims access
CREATE POLICY "assessment_access" ON public.damage_assessments
FOR ALL TO authenticated
USING (public.can_access_claim(claim_id))
WITH CHECK (public.can_access_claim(claim_id));

-- Claim images: Same as claims access
CREATE POLICY "image_access" ON public.claim_images
FOR ALL TO authenticated
USING (public.can_access_claim(claim_id))
WITH CHECK (public.can_access_claim(claim_id));

-- Claim activities: Same as claims access
CREATE POLICY "activity_access" ON public.claim_activities
FOR ALL TO authenticated
USING (public.can_access_claim(claim_id))
WITH CHECK (public.can_access_claim(claim_id));

-- 7. Functions for automatic profile creation and claim number generation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')::public.user_role
  );
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to generate claim numbers
CREATE OR REPLACE FUNCTION public.generate_claim_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    claim_number TEXT;
    year_suffix TEXT;
    sequence_num INTEGER;
BEGIN
    year_suffix := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    
    -- Get next sequence number for this year
    SELECT COALESCE(MAX(CAST(SUBSTRING(claim_number FROM 'CLM-' || year_suffix || '-(.*)') AS INTEGER)), 0) + 1
    INTO sequence_num
    FROM public.insurance_claims
    WHERE claim_number LIKE 'CLM-' || year_suffix || '-%';
    
    claim_number := 'CLM-' || year_suffix || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN claim_number;
END;
$$;

-- Function to automatically set claim number
CREATE OR REPLACE FUNCTION public.set_claim_number()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.claim_number IS NULL OR NEW.claim_number = '' THEN
        NEW.claim_number := public.generate_claim_number();
    END IF;
    RETURN NEW;
END;
$$;

-- Trigger to set claim number before insert
CREATE TRIGGER set_claim_number_trigger
    BEFORE INSERT ON public.insurance_claims
    FOR EACH ROW EXECUTE FUNCTION public.set_claim_number();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Triggers for updating timestamps
CREATE TRIGGER handle_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_insurance_policies
    BEFORE UPDATE ON public.insurance_policies
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_vehicles
    BEFORE UPDATE ON public.vehicles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_insurance_claims
    BEFORE UPDATE ON public.insurance_claims
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_damage_assessments
    BEFORE UPDATE ON public.damage_assessments
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 8. Mock Data for Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    adjuster_uuid UUID := gen_random_uuid();
    customer1_uuid UUID := gen_random_uuid();
    customer2_uuid UUID := gen_random_uuid();
    policy1_uuid UUID := gen_random_uuid();
    policy2_uuid UUID := gen_random_uuid();
    vehicle1_uuid UUID := gen_random_uuid();
    vehicle2_uuid UUID := gen_random_uuid();
    claim1_uuid UUID := gen_random_uuid();
    claim2_uuid UUID := gen_random_uuid();
    claim3_uuid UUID := gen_random_uuid();
    assessment1_uuid UUID := gen_random_uuid();
    assessment2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@claimsnap.com', crypt('ClaimSnap123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "System Administrator", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (adjuster_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'adjuster@claimsnap.com', crypt('ClaimSnap123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Claims Adjuster", "role": "adjuster"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (customer1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@claimsnap.com', crypt('ClaimSnap123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Smith", "role": "customer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (customer2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane@claimsnap.com', crypt('ClaimSnap123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Doe", "role": "customer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create insurance policies
    INSERT INTO public.insurance_policies (id, policy_holder_id, policy_number, policy_type, coverage_amount, deductible_amount, start_date, end_date)
    VALUES
        (policy1_uuid, customer1_uuid, 'POL-2024-001', 'Comprehensive Auto', 100000.00, 500.00, '2024-01-01', '2024-12-31'),
        (policy2_uuid, customer2_uuid, 'POL-2024-002', 'Liability Plus', 75000.00, 250.00, '2024-06-01', '2025-05-31');

    -- Create vehicles
    INSERT INTO public.vehicles (id, owner_id, policy_id, vehicle_type, make, model, year, vin, license_plate, color, estimated_value)
    VALUES
        (vehicle1_uuid, customer1_uuid, policy1_uuid, 'car'::public.vehicle_type, 'Honda', 'Civic', 2022, '1HGBH41JXMN109186', 'ABC123', 'Blue', 25000.00),
        (vehicle2_uuid, customer2_uuid, policy2_uuid, 'suv'::public.vehicle_type, 'Toyota', 'RAV4', 2021, '2T3BFREV0CW123456', 'XYZ789', 'Red', 32000.00);

    -- Create insurance claims
    INSERT INTO public.insurance_claims (id, policy_id, vehicle_id, claimant_id, adjuster_id, status, incident_date, incident_location, incident_description, estimated_damage_amount, deductible_amount)
    VALUES
        (claim1_uuid, policy1_uuid, vehicle1_uuid, customer1_uuid, adjuster_uuid, 'under_review'::public.claim_status, now() - interval '5 days', 'Downtown Parking Garage', 'Front bumper damage from parking lot incident', 2450.00, 500.00),
        (claim2_uuid, policy2_uuid, vehicle2_uuid, customer2_uuid, adjuster_uuid, 'approved'::public.claim_status, now() - interval '12 days', 'Home Driveway', 'Side panel dent from hail damage', 5200.00, 250.00),
        (claim3_uuid, policy1_uuid, vehicle1_uuid, customer1_uuid, null, 'submitted'::public.claim_status, now() - interval '3 days', 'Highway 101', 'Rear window crack from road debris', 1800.00, 500.00);

    -- Create damage assessments
    INSERT INTO public.damage_assessments (id, claim_id, assessor_id, assessment_type, severity, damage_description, affected_areas, estimated_cost, confidence_score)
    VALUES
        (assessment1_uuid, claim1_uuid, adjuster_uuid, 'ai_generated', 'moderate'::public.damage_severity, 'Front bumper shows impact damage with plastic deformation', '["front_bumper", "grille"]'::jsonb, 2450.00, 0.87),
        (assessment2_uuid, claim2_uuid, adjuster_uuid, 'manual', 'minor'::public.damage_severity, 'Multiple small dents on driver side panel from hail', '["left_side_panel", "left_door"]'::jsonb, 5200.00, null);

    -- Create claim images
    INSERT INTO public.claim_images (claim_id, assessment_id, uploaded_by, image_url, image_name, description, is_primary)
    VALUES
        (claim1_uuid, assessment1_uuid, customer1_uuid, 'https://images.pexels.com/photos/1213294/pexels-photo-1213294.jpeg?auto=compress&cs=tinysrgb&w=800', 'front_damage_1.jpg', 'Front bumper damage - primary view', true),
        (claim1_uuid, assessment1_uuid, customer1_uuid, 'https://images.pexels.com/photos/544542/pexels-photo-544542.jpeg?auto=compress&cs=tinysrgb&w=800', 'front_damage_2.jpg', 'Front bumper damage - side angle', false),
        (claim2_uuid, assessment2_uuid, customer2_uuid, 'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=800', 'hail_damage_1.jpg', 'Hail damage on side panel', true);

    -- Create claim activities
    INSERT INTO public.claim_activities (claim_id, user_id, activity_type, description, new_value)
    VALUES
        (claim1_uuid, customer1_uuid, 'status_change', 'Claim submitted for review', 'submitted'),
        (claim1_uuid, adjuster_uuid, 'status_change', 'Claim moved to under review', 'under_review'),
        (claim1_uuid, adjuster_uuid, 'assessment_added', 'AI damage assessment completed', 'assessment_completed'),
        (claim2_uuid, customer2_uuid, 'status_change', 'Claim submitted for review', 'submitted'),
        (claim2_uuid, adjuster_uuid, 'status_change', 'Claim approved for payment', 'approved');

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating mock data: %', SQLERRM;
END $$;

-- 9. Storage bucket for claim images (to be created in Supabase dashboard)
-- Bucket name: 'claim-images'
-- Public access: false (controlled by RLS)
-- File size limit: 10MB
-- Allowed file types: image/jpeg, image/png, image/webp

COMMENT ON TABLE public.user_profiles IS 'User profiles linked to auth.users for application data';
COMMENT ON TABLE public.insurance_policies IS 'Insurance policies owned by users';
COMMENT ON TABLE public.vehicles IS 'Vehicles covered under insurance policies';
COMMENT ON TABLE public.insurance_claims IS 'Insurance claims for vehicle damage';
COMMENT ON TABLE public.damage_assessments IS 'AI and manual damage assessments for claims';
COMMENT ON TABLE public.claim_images IS 'Images uploaded for insurance claims';
COMMENT ON TABLE public.claim_activities IS 'Activity timeline for insurance claims';