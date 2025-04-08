from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import asyncio

router = APIRouter()

async def simulate_taxi_route(start, end, steps=20):
    for i in range(steps + 1):
        lat = start[0] + (end[0] - start[0]) * i / steps
        lng = start[1] + (end[1] - start[1]) * i / steps
        yield {"latitude": lat, "longitude": lng}
        await asyncio.sleep(1)

@router.websocket("/ws/taxi_location")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        # 시작 및 목적지 좌표
        start = (37.55591036718129, 126.92295108368768)  # 도로 기반으로 조정된 좌표
        end = (37.555824, 126.9228913)

        async for location in simulate_taxi_route(start, end):
            await websocket.send_json(location)

    except WebSocketDisconnect:
        print("Client disconnected")
