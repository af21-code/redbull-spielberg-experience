package model;

public class VehicleSpec {
    private String code;        // "F1" | "F2" | "NASCAR"
    private String name;        // label visibile
    private String power;       // es. "1000 cv"
    private String topSpeed;    // es. "350 km/h"
    private String zeroTo100;   // es. "2.3 s"
    private String transmission;// es. "Sequenziale 8 marce"
    private String imageUrl;    // es. "images/vehicles/f1_rb21.png"

    public VehicleSpec() {}
    public VehicleSpec(String code, String name, String power, String topSpeed,
                       String zeroTo100, String transmission, String imageUrl) {
        this.code = code; this.name = name; this.power = power; this.topSpeed = topSpeed;
        this.zeroTo100 = zeroTo100; this.transmission = transmission; this.imageUrl = imageUrl;
    }

    public String getCode() { return code; }
    public String getName() { return name; }
    public String getPower() { return power; }
    public String getTopSpeed() { return topSpeed; }
    public String getZeroTo100() { return zeroTo100; }
    public String getTransmission() { return transmission; }
    public String getImageUrl() { return imageUrl; }
}