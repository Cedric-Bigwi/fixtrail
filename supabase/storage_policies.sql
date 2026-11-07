-- Run in Supabase: SQL Editor > New query > paste > Run
-- (Create the bucket first: Storage > New bucket > name: incident-photos > Public ON)

-- Photos are visible to anyone who has the link (public bucket) and the app can list/read them
create policy "incident photos: read"
on storage.objects for select
to anon
using (bucket_id = 'incident-photos');

-- The app (using the publishable key) can upload photos
create policy "incident photos: upload"
on storage.objects for insert
to anon
with check (bucket_id = 'incident-photos');

-- The app can remove a photo when a report is edited or deleted
create policy "incident photos: delete"
on storage.objects for delete
to anon
using (bucket_id = 'incident-photos');
