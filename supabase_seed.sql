-- =============================================================================
-- EVENTORA: SUPABASE SEED DATA SCRIPT (11 Events: Featured, Nearby & Upcoming)
-- Run this directly in your Supabase Dashboard -> SQL Editor
-- =============================================================================

-- 1. Backfill profiles for any existing auth.users (if not already present)
insert into public.profiles (id, full_name, email)
select
  u.id,
  coalesce(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)),
  u.email
from auth.users u
on conflict (id) do nothing;

-- 2. Allow organizer_id to be nullable for system-seeded events
-- (in case no user has signed up yet when running this script)
alter table public.events alter column organizer_id drop not null;

-- 3. Remove existing seed events with the same titles to avoid duplicates on re-run
delete from public.events
where title in (
  'Global AI & Flutter Summit',
  'Neon Rooftop Music Night',
  'Cloud Native & DevOps Live',
  'Startup Pitch & Networking',
  'Art & Wine Evening',
  'Morning Run & Coffee Club',
  'Open Mic Standup Comedy',
  'Live UI/UX Figma Critiques',
  'Design Systems Workshop',
  'Photography Walk: Old City',
  'Web3 & Rust Global Townhall'
);

-- 4. Insert all 11 Eventora Events (Featured, Nearby, and Upcoming; Offline & Online)
insert into public.events (
  organizer_id,
  title,
  description,
  category,
  event_mode,
  starts_at,
  venue_name,
  address,
  city,
  online_platform,
  meeting_url,
  is_free,
  price,
  max_capacity,
  is_featured
)
values
  -- ================= FEATURED EVENTS (4) =================
  (
    (select id from public.profiles limit 1),
    'Global AI & Flutter Summit',
    'Join top engineers and designers to explore next-gen AI integrations with Flutter, live demos, and networking.',
    'Tech',
    'offline',
    '2026-04-18 10:00:00+00',
    'Grand Convention Center, Hall A',
    '2.4 km away',
    'standard',
    null,
    null,
    false,
    49,
    240,
    true
  ),
  (
    (select id from public.profiles limit 1),
    'Neon Rooftop Music Night',
    'An unforgettable night under the stars featuring indie electronic artists, live synth sets, and craft mocktails.',
    'Music',
    'offline',
    '2026-04-19 20:30:00+00',
    'Skyline Lounge, Downtown',
    '1.8 km away',
    'standard',
    null,
    null,
    false,
    25,
    180,
    true
  ),
  (
    (select id from public.profiles limit 1),
    'Cloud Native & DevOps Live',
    'Interactive global livestream covering Kubernetes scaling, zero-downtime deployments, and live Q&A with cloud architects.',
    'Tech',
    'online',
    '2026-04-21 19:00:00+00',
    null,
    null,
    'standard',
    'YouTube Live',
    'https://live.eventora.dev/cloud-native',
    true,
    0,
    520,
    true
  ),
  (
    (select id from public.profiles limit 1),
    'Startup Pitch & Networking',
    'Meet early-stage founders, angel investors, and product builders. Pitch your idea in 3 minutes or connect over coffee.',
    'Business',
    'offline',
    '2026-04-22 17:00:00+00',
    'The Hub Co-Working Space',
    '3.1 km away',
    'standard',
    null,
    null,
    true,
    0,
    95,
    true
  ),

  -- ================= NEARBY EVENTS (4) =================
  (
    (select id from public.profiles limit 1),
    'Art & Wine Evening',
    'Unwind with guided canvas painting, curated acoustic music, and great company in an intimate gallery setting.',
    'Art',
    'offline',
    '2026-04-12 18:00:00+00',
    'Modern Art Studio, West End',
    '0.8 km away',
    'nearby',
    null,
    null,
    false,
    35,
    42,
    false
  ),
  (
    (select id from public.profiles limit 1),
    'Morning Run & Coffee Club',
    'A friendly 5K community pace run followed by specialty pour-over coffee and fresh pastries.',
    'Sports',
    'offline',
    '2026-04-13 06:30:00+00',
    'Central Park North Gate',
    '1.2 km away',
    'nearby',
    null,
    null,
    true,
    0,
    110,
    false
  ),
  (
    (select id from public.profiles limit 1),
    'Open Mic Standup Comedy',
    'Laugh out loud with 8 local comedians testing brand new material. Grab a front-row table early!',
    'Music',
    'offline',
    '2026-04-15 21:00:00+00',
    'The Basement Club',
    '2.1 km away',
    'nearby',
    null,
    null,
    false,
    15,
    68,
    false
  ),
  (
    (select id from public.profiles limit 1),
    'Live UI/UX Figma Critiques',
    'Submit your app screens for real-time feedback on layout, typography, and micro-interactions from senior product designers.',
    'Art',
    'online',
    '2026-04-16 20:00:00+00',
    null,
    null,
    'nearby',
    'Zoom Webinar',
    'https://zoom.us/j/eventora-figma',
    true,
    0,
    190,
    false
  ),

  -- ================= UPCOMING EVENTS (3) =================
  (
    (select id from public.profiles limit 1),
    'Design Systems Workshop',
    'Hands-on workshop covering Figma tokens, multi-brand theming, and building scalable Flutter component libraries.',
    'Tech',
    'online',
    '2026-04-25 11:00:00+00',
    null,
    null,
    'standard',
    'Google Meet',
    'https://meet.google.com/evn-dsgn-sys',
    false,
    19,
    130,
    false
  ),
  (
    (select id from public.profiles limit 1),
    'Photography Walk: Old City',
    'Golden hour street photography walk led by award-winning photojournalists. All cameras and smartphones welcome.',
    'Art',
    'offline',
    '2026-04-27 16:30:00+00',
    'Heritage Square Clocktower',
    '3.5 km away',
    'standard',
    null,
    null,
    true,
    0,
    54,
    false
  ),
  (
    (select id from public.profiles limit 1),
    'Web3 & Rust Global Townhall',
    'Deep dive into high-performance distributed systems, zero-knowledge proofs, and live code walkthroughs.',
    'Tech',
    'online',
    '2026-04-29 18:30:00+00',
    null,
    null,
    'standard',
    'Discord Stage',
    'https://discord.gg/eventora-rust',
    true,
    0,
    310,
    false
  );

