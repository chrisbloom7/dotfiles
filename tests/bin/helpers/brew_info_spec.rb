# tests/bin/helpers/brew_info_spec.rb
# Tests for bin/helpers/brew_info.rb
#
# Run with: ruby tests/bin/helpers/brew_info_spec.rb

require 'minitest/autorun'
require 'minitest/spec'
require 'json'
require 'tmpdir'
require 'fileutils'

HELPERS_DIR = File.expand_path('../../../bin/helpers', __dir__) unless defined?(HELPERS_DIR)
require File.join(HELPERS_DIR, 'brew_info')

# ---------------------------------------------------------------------------
# Helper: stub the `brew` binary via a temp dir on PATH
# ---------------------------------------------------------------------------
# Writes a mock brew script to a temp dir and prepends it to PATH for the
# duration of the block. The mock writes `stdout` to STDOUT and exits with
# `exit_status`.  `stdout` must be valid for shell embedding (no raw newlines
# in the script body — we write it to a fixture file instead).
#
module BrewStubHelper
  def with_mock_brew(stdout:, stderr: '', exit_status: 0)
    Dir.mktmpdir('brew_info_spec') do |dir|
      fixture = File.join(dir, 'brew_output.json')
      File.write(fixture, stdout)

      err_fixture = File.join(dir, 'brew_stderr.txt')
      File.write(err_fixture, stderr)

      brew_path = File.join(dir, 'brew')
      File.write(brew_path, <<~BASH)
        #!/usr/bin/env bash
        cat #{fixture}
        cat #{err_fixture} >&2
        exit #{exit_status}
      BASH
      FileUtils.chmod(0o755, brew_path)

      old_path = ENV['PATH']
      ENV['PATH'] = "#{dir}:#{old_path}"
      begin
        yield
      ensure
        ENV['PATH'] = old_path
      end
    end
  end

  def formula_json(name:, desc: 'A formula description')
    JSON.generate('formulae' => [{ 'name' => name, 'desc' => desc }], 'casks' => [])
  end

  def cask_json(token:, desc: 'A cask description')
    JSON.generate('formulae' => [], 'casks' => [{ 'token' => token, 'desc' => desc }])
  end

  def multi_json(formulae: [], casks: [])
    JSON.generate(
      'formulae' => formulae.map { |f| { 'name' => f[:name], 'desc' => f[:desc] } },
      'casks'    => casks.map    { |c| { 'token' => c[:name], 'desc' => c[:desc] } }
    )
  end
end

# ---------------------------------------------------------------------------
# Specs
# ---------------------------------------------------------------------------
describe BrewInfo do
  include BrewStubHelper

  # -------------------------------------------------------------------------
  # Argument validation
  # -------------------------------------------------------------------------
  describe '.lookup' do
    it 'raises ArgumentError when no names given' do
      _(proc { BrewInfo.lookup([]) }).must_raise ArgumentError
    end

    it 'raises ArgumentError when names is nil (Array(nil) is empty)' do
      _(proc { BrewInfo.lookup(nil) }).must_raise ArgumentError
    end

    # -----------------------------------------------------------------------
    # Formula lookup
    # -----------------------------------------------------------------------
    it 'returns a brew entry for a formula' do
      with_mock_brew(stdout: formula_json(name: 'git', desc: 'Distributed revision control')) do
        result = BrewInfo.lookup(['git'])
        _(result.length).must_equal 1
        _(result.first[:name]).must_equal 'git'
        _(result.first[:type]).must_equal 'brew'
        _(result.first[:description]).must_equal 'Distributed revision control'
      end
    end

    # -----------------------------------------------------------------------
    # Cask lookup
    # -----------------------------------------------------------------------
    it 'returns a cask entry for a cask' do
      with_mock_brew(stdout: cask_json(token: 'visual-studio-code', desc: 'Open-source code editor')) do
        result = BrewInfo.lookup(['visual-studio-code'])
        _(result.first[:name]).must_equal 'visual-studio-code'
        _(result.first[:type]).must_equal 'cask'
        _(result.first[:description]).must_equal 'Open-source code editor'
      end
    end

    # -----------------------------------------------------------------------
    # Multiple packages
    # -----------------------------------------------------------------------
    it 'returns entries for multiple packages' do
      json = multi_json(
        formulae: [{ name: 'git', desc: 'VCS' }, { name: 'fzf', desc: 'Fuzzy finder' }],
        casks:    [{ name: 'iterm2', desc: 'Terminal emulator' }]
      )
      with_mock_brew(stdout: json) do
        result = BrewInfo.lookup(['git', 'fzf', 'iterm2'])
        _(result.length).must_equal 3
        types = result.map { |r| r[:type] }
        _(types).must_include 'brew'
        _(types).must_include 'cask'
      end
    end

    # -----------------------------------------------------------------------
    # brew command failure
    # -----------------------------------------------------------------------
    it 'raises RuntimeError when brew exits non-zero' do
      _(proc {
        with_mock_brew(stdout: '', stderr: 'Error: No formula', exit_status: 1) do
          BrewInfo.lookup(['nonexistent-pkg'])
        end
      }).must_raise RuntimeError
    end

    it 'includes stderr in the error message on failure' do
      err = nil
      begin
        with_mock_brew(stdout: '', stderr: 'No formula found', exit_status: 1) do
          BrewInfo.lookup(['nonexistent-pkg'])
        end
      rescue RuntimeError => e
        err = e
      end
      _(err).wont_be_nil
      _(err.message).must_include 'No formula found'
    end

    # -----------------------------------------------------------------------
    # Package absent from results
    # -----------------------------------------------------------------------
    it 'raises RuntimeError when a requested package is not in results' do
      json = multi_json(formulae: [{ name: 'git', desc: 'VCS' }])
      _(proc {
        with_mock_brew(stdout: json) do
          BrewInfo.lookup(['git', 'missing-pkg'])
        end
      }).must_raise RuntimeError
    end

    it 'names the missing package in the error message' do
      json = multi_json(formulae: [{ name: 'git', desc: 'VCS' }])
      err  = nil
      begin
        with_mock_brew(stdout: json) do
          BrewInfo.lookup(['git', 'missing-pkg'])
        end
      rescue RuntimeError => e
        err = e
      end
      _(err).wont_be_nil
      _(err.message).must_include 'missing-pkg'
    end

    # -----------------------------------------------------------------------
    # Nil / absent description
    # -----------------------------------------------------------------------
    it 'returns nil description when desc key is absent from JSON' do
      json = JSON.generate('formulae' => [{ 'name' => 'nodesc' }], 'casks' => [])
      with_mock_brew(stdout: json) do
        result = BrewInfo.lookup(['nodesc'])
        _(result.first[:description]).must_be_nil
      end
    end
  end
end
