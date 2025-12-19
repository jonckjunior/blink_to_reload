pattern = {}
pattern.__index = pattern

-- a pattern has:
--      * upcoming attacks: a list of attacks.
-- example usage:
-- pattern:new(
--     upcoming_attacks = {
--         ring_attack:new(10, 20, 30, 20, 60),
--         ring_attack:new(50, 20, 10, 0, 60),
--         rectangle_attack:new(0, 100, 127, 120, 0, 60)
--     }
-- )

function pattern:new(upcoming_attacks)
    local p = {
        t = 0,
        attacks = {},
        upcoming_attacks = upcoming_attacks,
        done = false
    }
    setmetatable(p, self)
    return p
end

function pattern:update()
    -- we check to see if it's time to start any upcoming attack
    -- upcoming attacks are then moved to attacks
    for i = #self.upcoming_attacks, 1, -1 do
        local attack = self.upcoming_attacks[i]
        if attack.start_t == self.t then
            add(self.attacks, attack)
            del(self.upcoming_attacks, attack)
        end
    end

    -- for each attack that has been initiated, we update it and check to see if it's done
    for i = #self.attacks, 1, -1 do
        local attack = self.attacks[i]
        attack:update()
        if attack.done then
            del(self.attacks, attack)
        end
    end

    -- once we no longer have any attacks, this pattern can be deleted
    if #self.attacks == 0 and #self.upcoming_attacks == 0 then
        self.done = true
    end

    self.t += 1
end

function pattern:draw()
    -- draw all the attacks that have been initiated
    -- start with telegraph
    for attack in all(self.attacks) do
        if attack:is_telegraph() then
            attack:draw()
        end
    end

    -- now we draw active attacks
    for attack in all(self.attacks) do
        if attack:is_active() then
            attack:draw()
        end
    end
end