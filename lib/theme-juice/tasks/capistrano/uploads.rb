# encoding: UTF-8

namespace :uploads do

  desc "Push local uploads to remote"
  task :push do
    on roles(:app) do
      upload! fetch(:vm_uploads_dir), shared_path.join(Pathname.new(fetch(:uploads_dir)).parent), {
        recursive: true
      }
    end
  end

  desc "Pull remote uploads to local"
  task :pull do
    on roles(:app) do
      download! shared_path.join(fetch(:uploads_dir)), Pathname.new(fetch(:vm_uploads_dir)).parent, {
        recursive: true
      }
    end
  end
end
