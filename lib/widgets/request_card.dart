import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final bool isSupplier;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onContact;

  const RequestCard({
    super.key,
    required this.request,
    this.isSupplier = false,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onContact,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppTheme.primaryColor;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return AppTheme.errorColor;
      case 'pending':
      default:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(request.status);
    String formattedDate = DateFormat('MMM dd, yyyy').format(request.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.materialName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Requested Quantity & User Info
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Text(
                'Requested: ${request.requestedQuantity}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(isSupplier ? Icons.person_outline : Icons.store_outlined,
                  size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Text(
                isSupplier ? 'Maker: ${request.makerName}' : 'Supplier: ${request.supplierName}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimaryColor),
              ),
            ],
          ),

          if (request.purpose.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Purpose: ${request.purpose}\n"${request.message}"',
                style: const TextStyle(fontSize: 12, color: AppTheme.textPrimaryColor, fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Supplier Action Buttons
          if (isSupplier && request.status == AppConstants.requestPending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],

          if (isSupplier && request.status == AppConstants.requestAccepted) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark as Collected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Maker Action Button (Contact Supplier when Accepted)
          if (!isSupplier && request.status == AppConstants.requestAccepted) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Contact Supplier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
