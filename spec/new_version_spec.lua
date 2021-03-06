local test_env = require("test/test_environment")
local lfs = require("lfs")
local run = test_env.run
local testing_paths = test_env.testing_paths

test_env.unload_luarocks()

local extra_rocks = test_env.mock_server_extra_rocks({
   "/abelhas-1.0-1.rockspec",
   "/lpeg-0.12-1.rockspec"
})

describe("LuaRocks new_version tests #blackbox #b_new_version", function()

   before_each(function()
      test_env.setup_specs(extra_rocks)
   end)
   
   describe("basic tests", function()
      it("with no flags/arguments", function()
         lfs.chdir("test")
         assert.is_false(run.luarocks_bool("new_version"))
         lfs.chdir(testing_paths.luarocks_dir)
      end)
      
      it("with invalid", function()
         assert.is_false(run.luarocks_bool("new_version invalid"))
      end)

      it("with invalid url", function()
         assert.is_true(run.luarocks_bool("download --rockspec abelhas 1.0"))
         assert.is_true(run.luarocks_bool("new_version abelhas-1.0-1.rockspec 1.1 http://luainvalid"))
         assert.is.truthy(lfs.attributes("abelhas-1.1-1.rockspec"))
         test_env.remove_files(lfs.currentdir(), "abelhas--")
      end)
   end)

   describe("more complex tests", function()
      it("of luacov", function()
         assert.is_true(run.luarocks_bool("download --rockspec luacov 0.11.0"))
         assert.is_true(run.luarocks_bool("new_version luacov-0.11.0-1.rockspec 0.2"))
         assert.is.truthy(lfs.attributes("luacov-0.2-1.rockspec"))
         test_env.remove_files(lfs.currentdir(), "luacov--")
      end)

      it("url of abelhas", function()
         assert.is_true(run.luarocks_bool("download --rockspec abelhas 1.0"))
         assert.is_true(run.luarocks_bool("new_version abelhas-1.0-1.rockspec 1.1 http://luaforge.net/frs/download.php/2658/abelhas-1.0.tar.gz"))
         assert.is.truthy(lfs.attributes("abelhas-1.1-1.rockspec"))
         test_env.remove_files(lfs.currentdir(), "abelhas--")
      end)
      
      it("of luacov with tag", function()
         assert.is_true(run.luarocks_bool("download --rockspec luacov 0.11.0"))
         assert.is_true(run.luarocks_bool("new_version luacov-0.11.0-1.rockspec --tag v0.3"))
         assert.is.truthy(lfs.attributes("luacov-0.3-1.rockspec"))
         test_env.remove_files(lfs.currentdir(), "luacov--")
      end)

      it("updating md5", function()
         assert.is_true(run.luarocks_bool("download --rockspec lpeg 0.12"))
         assert.is_true(run.luarocks_bool("new_version lpeg-0.12-1.rockspec 0.2 https://luarocks.org/manifests/gvvaughan/lpeg-1.0.0-1.rockspec"))
         test_env.remove_files(lfs.currentdir(), "lpeg--")
      end)
   end)

   describe("remote tests #mock", function()
      it("with remote spec", function()
         test_env.mock_server_init()
         assert.is_true(run.luarocks_bool("new_version http://localhost:8080/file/a_rock-1.0-1.rockspec"))
         assert.is.truthy(lfs.attributes("a_rock-1.0-1.rockspec"))
         assert.is.truthy(lfs.attributes("a_rock-1.0-2.rockspec"))
         test_env.remove_files(lfs.currentdir(), "luasocket--")
         test_env.mock_server_done()
      end)
   end)

end)
