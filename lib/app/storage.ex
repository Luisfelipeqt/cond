defmodule App.Storage do
  @moduledoc "Wrapper S3 via ExAws para upload de documentos e resumos."

  def bucket, do: Application.fetch_env!(:app, :s3_bucket)

  @doc "Faz upload de um arquivo local para o S3 via streaming."
  def upload(local_path, s3_key, content_type \\ "application/octet-stream") do
    local_path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(bucket(), s3_key, content_type: content_type, acl: :private)
    |> ExAws.request()
    |> case do
      {:ok, _} -> {:ok, public_url(s3_key)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Faz upload de um binário diretamente para o S3."
  def upload_binary(binary, s3_key, content_type) do
    bucket()
    |> ExAws.S3.put_object(s3_key, binary, content_type: content_type, acl: :private)
    |> ExAws.request()
    |> case do
      {:ok, _} -> {:ok, public_url(s3_key)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp public_url(key) do
    region = Application.get_env(:ex_aws, :region, "us-east-1")
    "https://#{bucket()}.s3.#{region}.amazonaws.com/#{key}"
  end
end
