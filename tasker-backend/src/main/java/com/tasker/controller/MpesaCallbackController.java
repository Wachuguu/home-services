package com.tasker.controller;

import com.tasker.service.PaymentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/mpesa")
public class MpesaCallbackController {

    private final PaymentService paymentService;

    public MpesaCallbackController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/stk-callback")
    public ResponseEntity<Void> handleSTKCallback(@RequestBody Map<String, Object> callbackData) {
        paymentService.handleSTKCallback(callbackData);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/b2c-result")
    public ResponseEntity<Void> handleB2CResult(@RequestBody Map<String, Object> resultData) {
        paymentService.handleB2CCallback(resultData);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/b2c-timeout")
    public ResponseEntity<Void> handleB2CTimeout(@RequestBody Map<String, Object> timeoutData) {
        return ResponseEntity.ok().build();
    }
}
