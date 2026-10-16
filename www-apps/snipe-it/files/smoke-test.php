<?php
// Exercise the production autoloader and image/PDF code without a database.
require getcwd().'/vendor/autoload.php';

$barcode = (new Com\Tecnick\Barcode\Barcode())->getBarcodeObj('C128', 'SNIPE123', 200, 50);
$png = $barcode->getPngData();
if (!str_starts_with($png, "\x89PNG\r\n\x1a\n")) {
    throw new RuntimeException('Barcode PNG generation failed');
}

$images = new Intervention\Image\ImageManager(['driver' => 'gd']);
$image = $images->make($png)->resize(100, 25);
if ($image->width() !== 100 || $image->height() !== 25) {
    throw new RuntimeException('Image resizing failed');
}

$pdf = new TCPDF();
$pdf->AddPage();
$pdf->SetFont('dejavusans', '', 10);
$pdf->Write(0, 'Snipe-IT smoke test');
$document = $pdf->Output('smoke.pdf', 'S');
if (!str_starts_with($document, '%PDF-')) {
    throw new RuntimeException('PDF generation failed');
}
echo "Production autoload, barcode PNG, GD resize and PDF generation: OK\n";
