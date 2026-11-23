CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('app', 'web', 'both')),
  official_url text,
  android_package_name text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE practice_sets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid NOT NULL REFERENCES services(id),
  platform text NOT NULL CHECK (platform IN ('web', 'android', 'ios', 'all')),
  target_version text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  reviewed_at timestamptz,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX one_published_practice_set
  ON practice_sets(service_id, platform) WHERE status = 'published';

CREATE TABLE practice_screens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  practice_set_id uuid NOT NULL REFERENCES practice_sets(id),
  title text NOT NULL,
  asset_url text NOT NULL,
  position integer NOT NULL CHECK (position > 0),
  UNIQUE (practice_set_id, position)
);

CREATE TABLE screen_hotspots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_id uuid NOT NULL REFERENCES practice_screens(id),
  label text NOT NULL,
  description text NOT NULL,
  x numeric(5,4) NOT NULL CHECK (x >= 0 AND x <= 1),
  y numeric(5,4) NOT NULL CHECK (y >= 0 AND y <= 1),
  width numeric(5,4) NOT NULL CHECK (width > 0 AND x + width <= 1),
  height numeric(5,4) NOT NULL CHECK (height > 0 AND y + height <= 1),
  target_screen_id uuid REFERENCES practice_screens(id),
  UNIQUE (id, screen_id)
);

CREATE TABLE tutorials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid NOT NULL REFERENCES services(id),
  slug text NOT NULL,
  platform text NOT NULL CHECK (platform IN ('web', 'android', 'ios', 'all')),
  locale text NOT NULL DEFAULT 'ko',
  current_published_version_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (service_id, slug, platform, locale)
);

CREATE TABLE tutorial_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tutorial_id uuid NOT NULL REFERENCES tutorials(id),
  practice_set_id uuid NOT NULL REFERENCES practice_sets(id),
  version_number integer NOT NULL CHECK (version_number > 0),
  status text NOT NULL CHECK (status IN ('draft', 'published')),
  title text NOT NULL,
  goal text NOT NULL,
  target_version text,
  prerequisites jsonb NOT NULL DEFAULT '[]'::jsonb,
  estimated_minutes integer CHECK (estimated_minutes > 0),
  reviewed_at timestamptz,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tutorial_id, version_number),
  UNIQUE (id, tutorial_id),
  CHECK ((status = 'published' AND published_at IS NOT NULL) OR status = 'draft')
);

CREATE UNIQUE INDEX one_draft_per_tutorial ON tutorial_versions(tutorial_id) WHERE status = 'draft';

ALTER TABLE tutorials ADD CONSTRAINT current_version_belongs_to_tutorial
  FOREIGN KEY (current_published_version_id, id)
  REFERENCES tutorial_versions(id, tutorial_id);

CREATE TABLE steps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tutorial_version_id uuid NOT NULL REFERENCES tutorial_versions(id),
  screen_id uuid NOT NULL REFERENCES practice_screens(id),
  expected_hotspot_id uuid,
  position integer NOT NULL CHECK (position > 0),
  title text NOT NULL,
  body text NOT NULL,
  deep_link text,
  FOREIGN KEY (expected_hotspot_id, screen_id) REFERENCES screen_hotspots(id, screen_id),
  UNIQUE (tutorial_version_id, position),
  UNIQUE (id, tutorial_version_id)
);

CREATE TABLE feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tutorial_version_id uuid NOT NULL REFERENCES tutorial_versions(id),
  step_id uuid,
  helpful boolean,
  report_text text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (helpful IS NOT NULL OR NULLIF(trim(report_text), '') IS NOT NULL),
  FOREIGN KEY (step_id, tutorial_version_id) REFERENCES steps(id, tutorial_version_id)
);

CREATE INDEX tutorials_by_service ON tutorials(service_id);
CREATE INDEX versions_by_tutorial ON tutorial_versions(tutorial_id, version_number DESC);
CREATE INDEX feedback_newest_first ON feedback(created_at DESC);
