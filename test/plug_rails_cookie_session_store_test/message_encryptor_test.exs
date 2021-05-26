defmodule PlugRailsCookieSessionStore.MessageEncryptorTest do
  use ExUnit.Case, async: true

  alias PlugRailsCookieSessionStore.MessageEncryptor, as: ME

  @right String.duplicate("abcdefgh", 4)
  @wrong String.duplicate("12345678", 4)
  @large String.duplicate(@right, 2)

  test "it encrypts/decrypts a message" do
    data = <<0, "hełłoworld", 0>>
    encrypted = ME.encrypt_and_sign(<<0, "hełłoworld", 0>>, @right, @right)

    decrypted = ME.verify_and_decrypt(encrypted, @right, @wrong)
    assert decrypted == :error

    decrypted = ME.verify_and_decrypt(encrypted, @wrong, @right)
    assert decrypted == :error

    decrypted = ME.verify_and_decrypt(encrypted, @right, @right)
    assert decrypted == {:ok, data}
  end

  test "it uses only the first 32 bytes to encrypt/decrypt" do
    data = <<0, "helloworld", 0>>
    encrypted = ME.encrypt_and_sign(<<0, "helloworld", 0>>, @large, @large)

    decrypted = ME.verify_and_decrypt(encrypted, @large, @large)
    assert decrypted == {:ok, data}

    decrypted = ME.verify_and_decrypt(encrypted, @right, @large)
    assert decrypted == {:ok, data}

    decrypted = ME.verify_and_decrypt(encrypted, @large, @right)
    assert decrypted == :error

    decrypted = ME.verify_and_decrypt(encrypted, @right, @right)
    assert decrypted == :error

    encrypted = ME.encrypt_and_sign(<<0, "helloworld", 0>>, @right, @large)

    decrypted = ME.verify_and_decrypt(encrypted, @large, @large)
    assert decrypted == {:ok, data}

    decrypted = ME.verify_and_decrypt(encrypted, @right, @large)
    assert decrypted == {:ok, data}

    decrypted = ME.verify_and_decrypt(encrypted, @large, @right)
    assert decrypted == :error

    decrypted = ME.verify_and_decrypt(encrypted, @right, @right)
    assert decrypted == :error
  end
end
