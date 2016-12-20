require 'pathname'
require 'fileutils'
require 'git'

module FetchLocalLib
    class Repo
        def self.github(base_dir, repo_path, tag: nil)
            Repo.new("git@github.com:#{repo_path}.git", base_dir, tag: tag)
        end

        def self.bitbucket(base_dir, repo_name, owner: 'fathens', tag: nil)
            Repo.new("git@bitbucket.org:#{owner}/#{repo_name}.git", base_dir, tag: tag)
        end

        attr_accessor :url, :name, :base_dir, :hidden_path, :tag

        def initialize(url, base_dir = nil, tag: nil)
            @url = url
            @name = File.basename(url.split('/').last, '.git')
            @base_dir = base_dir || Pathname.pwd
            @hidden_path = '.repo'
            @tag = tag || "master"
        end

        def dir
            base_dir/hidden_path/name
        end

        def cloned
            @cloned ||= begin
                g = Git.open(dir)
                g.remotes.map(&:url).find(url) ? g : nil
            rescue => ex
                nil
            end
        end

        def git_clone
            if dir.exist?
                if cloned
                    cloned.checkout(tag)
                    return dir
                end
                FileUtils.rm_rf(dir)
            end
            begin
                retry_count ||= 0
                Git.clone(url, name, path: dir.dirname.to_s).checkout(tag)
            rescue
                retry if (retry_count += 1) < 3
            end
            return dir
        end
    end
end
