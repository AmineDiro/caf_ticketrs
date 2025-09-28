use futures::future::join_all;
use wtransport::ClientConfig;
use wtransport::Endpoint;
use wtransport::VarInt;

const N_CLIENTS: usize = 1 << 20;

async fn spawn_client() {
    let config = ClientConfig::builder()
        .with_bind_default()
        .with_no_cert_validation()
        .build();

    let connection = Endpoint::client(config)
        .unwrap()
        .connect("https://rig:4433")
        .await
        .unwrap();

    let mut stream = connection.open_bi().await.unwrap().await.unwrap();
    stream.0.write_all(b"HELLO").await.unwrap();
    stream.0.finish().await.unwrap();
    let mut buffer = [0u8; 1024];

    let n_bytes = stream
        .1
        .read(&mut buffer)
        .await
        .unwrap()
        .unwrap_or_default();

    let str_data = std::str::from_utf8(&buffer[..n_bytes]).unwrap();
    println!("Received (bi) '{str_data}' from  server");

    connection.close(VarInt::from(0u32), &[]);
}

#[tokio::main]
async fn main() {
    let handles = (0..N_CLIENTS).map(|_| tokio::spawn(spawn_client()));

    join_all(handles).await;
}
