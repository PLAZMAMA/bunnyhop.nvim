rockspec_format = '3.0'
-- TODO: Rename this file and set the package
package = "nvim-lua-plugin"
version = "scm-1"
source = {
  url = "git+https://github.com/PLAZMAMA/bunnyhop.nvim/"
}
dependencies = {
  -- Add runtime dependencies here
  -- e.g. "plenary.nvim",
}
test_dependencies = {
  "nlua"
}
build = {
  type = "builtin",
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}
