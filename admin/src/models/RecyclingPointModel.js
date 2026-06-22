class RecyclingPointModel {
  constructor(id, data) {
    this.id = id;
    this.pointCode = data.pointCode || "";
    this.name = data.name || "";
    this.address = data.address || "";
    this.latitude = data.latitude || 0;
    this.longitude = data.longitude || 0;
    this.hours = data.hours || "";
    this.status = data.status || "Unknown";
    this.isOpen = data.is_open === true;
    this.contact = data.contact || "";
    this.area = data.area || "";
    this.openingHours = data.opening_hours || {};
    this.types = Array.isArray(data.types) ? data.types : [];
  }

  getDisplayName() {
    if (this.pointCode) {
      return this.pointCode + " - " + this.name;
    }

    return this.name;
  }

  getTypeText() {
    if (this.types.length === 0) {
      return "-";
    }

    return this.types.join(", ");
  }
}

export default RecyclingPointModel;