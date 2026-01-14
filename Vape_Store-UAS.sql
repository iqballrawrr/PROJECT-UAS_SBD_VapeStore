CREATE DATABASE IF NOT EXISTS vape_storeV1;
USE vape_storeV1;

CREATE TABLE kasir (
    id_kasir VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL
);

CREATE TABLE karyawan (
    id_karyawan VARCHAR(20) PRIMARY KEY,
    nik VARCHAR(30) UNIQUE,
    nama_lengkap VARCHAR(50) NOT NULL,
    alamat VARCHAR(150),
    no_telepon VARCHAR(15)
);

CREATE TABLE operator (
    id_operator VARCHAR(20) PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    password VARCHAR(100) NOT NULL,
    id_karyawan VARCHAR(20),
    FOREIGN KEY (id_karyawan) REFERENCES karyawan(id_karyawan) ON DELETE CASCADE
);

CREATE TABLE shift (
    id_shift VARCHAR(20) PRIMARY KEY,
    nama_shift VARCHAR(30),
    jam_mulai TIME,
    jam_selesai TIME
);

CREATE TABLE jadwal (
    id_jadwal VARCHAR(20) PRIMARY KEY,
    id_karyawan VARCHAR(20),
    id_shift VARCHAR(20),
    id_kasir VARCHAR(20),
    tanggal DATE,
    status_hadir VARCHAR(20),
    check_in TIME,
    check_out TIME,
    FOREIGN KEY (id_karyawan) REFERENCES karyawan(id_karyawan),
    FOREIGN KEY (id_shift) REFERENCES shift(id_shift),
    FOREIGN KEY (id_kasir) REFERENCES kasir(id_kasir)
);

CREATE TABLE items (
    id_items VARCHAR(20) PRIMARY KEY,
    nama_item VARCHAR(50),
    harga INT,
    stock INT
);

CREATE TABLE transaksi (
    id_transaksi VARCHAR(20) PRIMARY KEY,
    id_kasir VARCHAR(20),
    id_operator VARCHAR(20),
    tanggal DATETIME DEFAULT CURRENT_TIMESTAMP,
    disc INT DEFAULT 0,
    ppn INT DEFAULT 0,
    total INT,
    FOREIGN KEY (id_kasir) REFERENCES kasir(id_kasir),
    FOREIGN KEY (id_operator) REFERENCES operator(id_operator)
);

CREATE TABLE transaksi_detail (
    id_detail VARCHAR(20) PRIMARY KEY,
    id_transaksi VARCHAR(20),
    id_items VARCHAR(20),
    kuantitas INT,
    subtotal INT,
    FOREIGN KEY (id_transaksi) REFERENCES transaksi(id_transaksi),
    FOREIGN KEY (id_items) REFERENCES items(id_items)
);

INSERT INTO karyawan VALUES 
('KRY001', '3201001010100001', 'Akiraizen Roosevelt', 'Jl. Arjuna No. 1', '087749011382'),
('KRY002', '3201001010100002', 'Joshua Ardiaz', 'Jl. Arjuna No. 2', '08125940392'),
('KRY003', '3201001050100002', 'Vyka Amanul Alam', 'Jl. Arjuna No. 7', '085950863703');

INSERT INTO kasir VALUES 
('KASIR001', 'Kasir Utama'),
('KASIR002', 'Kasir Cabang');

INSERT INTO operator VALUES 
('OPR001', 'admin_kasir', 'pass123', 'KRY001'),
('OPR002', 'admin_kasir2', 'pass123', 'KRY002');

INSERT INTO items VALUES 
('BRG001', 'Liquid Oatberry 60ml', 150000, 20),
('BRG002', 'Coil Alien Prebuild', 45000, 50),
('BRG003', 'Cartridge Ursa V2', 40000, 30);

UPDATE items SET stock = 15 WHERE id_items = 'BRG001';

START TRANSACTION;
    INSERT INTO transaksi (id_transaksi, id_kasir, id_operator, tanggal, disc, ppn, total)
    VALUES ('TRX001', 'KASIR001', 'OPR001', NOW(), 0, 1500, 151500);

    INSERT INTO transaksi_detail (id_detail, id_transaksi, id_items, kuantitas, subtotal)
    VALUES ('DTL001', 'TRX001', 'BRG001', 1, 150000);

    -- Mengurangi stok barang otomatis
    UPDATE items SET stock = stock - 1 WHERE id_items = 'BRG001';
COMMIT;

-- A. JOIN: Menampilkan Detail Transaksi Lengkap
SELECT 
    t.id_transaksi,
    t.tanggal,
    k.nama AS nama_kasir,
    i.nama_item,
    d.kuantitas,
    d.subtotal
FROM transaksi t
JOIN kasir k ON t.id_kasir = k.id_kasir
JOIN transaksi_detail d ON t.id_transaksi = d.id_transaksi
JOIN items i ON d.id_items = i.id_items;

-- B. AGREGASI & GROUP BY: Total Penjualan per Kasir
SELECT 
    k.nama AS nama_kasir,
    COUNT(t.id_transaksi) AS jumlah_transaksi,
    SUM(t.total) AS total_omzet
FROM transaksi t
JOIN kasir k ON t.id_kasir = k.id_kasir
GROUP BY k.nama;

-- C. HAVING: Mencari Item yang Stoknya di bawah 20
SELECT nama_item, stock
FROM items
GROUP BY id_items
HAVING stock < 20;

-- D. LEFT JOIN: Cek Karyawan yang belum punya akun Operator
SELECT 
    k.nama_lengkap, 
    o.username
FROM karyawan k
LEFT JOIN operator o ON k.id_karyawan = o.id_karyawan;
