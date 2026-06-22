class PickupRequestModel {
  constructor(id, data) {
    this.id = id;
    this.pickupId = data.pickupId || id;
    this.userId = data.userId || "";
    this.userNo = data.userNo || "";
    this.username = data.username || "Unknown User";
    this.pickupAddress = data.pickupAddress || "";
    this.unitNo = data.unitNo || "";
    this.postalCode = data.postalCode || "";
    this.remarks = data.remarks || "";
    this.status = data.status || "Pending";
    this.itemTypes = data.itemTypes || [];
    this.createdAt = data.createdAt || null;
    this.updatedAt = data.updatedAt || null;
    this.forwardedByAdminId = data.forwardedByAdminId || "";
    this.forwardedToPointId = data.forwardedToPointId || "";
    this.forwardedAt = data.forwardedAt || null;
  }

  getItemsText() {
    if (!this.itemTypes || this.itemTypes.length === 0) {
      return "-";
    }

    return this.itemTypes.join(", ");
  }

  getCreatedDateText() {
    if (!this.createdAt) {
      return "-";
    }

    return this.createdAt.toDate().toLocaleDateString();
  }
}

export default PickupRequestModel;