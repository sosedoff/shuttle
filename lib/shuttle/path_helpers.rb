module Shuttle
  module PathHelpers
    # Get deployment root path, everything is based from here
    # @return [String]
    def deploy_path(path=nil)
      [target.deploy_to, path].compact.join('/')
    end

    # Get shared path between releases
    # @return [String]
    def shared_path(path=nil)
      [deploy_path, 'shared', path].compact.join('/')
    end

    # Get path to currently used release
    # @return [String]
    def release_path(path=nil)
      [deploy_path, 'releases', version, path].compact.join('/')
    end

    # Get current release (symlinked) path
    # @return [String]
    def current_path(path=nil)
      [deploy_path, 'current', path].compact.join('/')
    end

    # Get path to release version file
    # @return [String]
    def version_path
      deploy_path('version')
    end

    # Get path to where repository code is stored
    # @return [String]
    def scm_path
      deploy_path('scm')
    end
  end
end